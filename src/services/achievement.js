/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';
import _ from 'lodash';

angular.module('swarmApp').factory('Achievement', function(util, $log, $rootScope, $filter) { let Achievement;
return Achievement = class Achievement {
  constructor(game, type) {
    this.game = game;
    this.type = type;
    this.name = this.type.name;
  }
  _init() {
    if (this.game.session.state.achievements == null) { this.game.session.state.achievements = {}; }
    this.requires = _.map(this.type.requires, require => {
      require = _.clone(require);
      if (require.unittype) {
        require.resource = (require.unit = util.assert(this.game.unit(require.unittype)));
      }
      if (require.upgradetype) {
        require.resource = (require.upgrade = util.assert(this.game.upgrade(require.upgradetype)));
      }
      util.assert(!(require.unit && require.upgrade), "achievement requirement can't have both unit and upgrade", this.name);
      return require;
    });
    util.assert(this.requires.length <= 1, 'multiple achievement requirements not yet supported', this.name);
    return this.visible = _.map(this.type.visible, visible => {
      visible = _.clone(visible);
      if (visible.unittype) {
        visible.resource = (visible.unit = util.assert(this.game.unit(visible.unittype)));
      }
      if (visible.upgradetype) {
        visible.resource = (visible.upgrade = util.assert(this.game.upgrade(visible.upgradetype)));
      }
      util.assert(!!visible.unit !== !!visible.upgrade, "achievement visiblity must have unit xor upgrade", this.name);
      return visible;
    });
  }

  description() {
    // "Why not angular templates?" I don't want to be forced to keep every
    // achievement description as a file, there's only one substitution needed,
    // and last time I tried to $compile spreadsheet data we leaked memory all
    // over the place. So, just do the one substitution.
    let desc = this.type.description;
    if ((this.type.requires.length > 0) && (this.type.requires[0].unittype || this.type.requires[0].upgradetype)) {
      // don't apply significant figures, achievement numbers are okay as-is
      desc = desc.replace('$REQUIRED', $filter('longnum')(this.type.requires[0].val, undefined, {sigfigs: undefined}));
    }
    return desc;
  }

  isEarned() {
    return (this.game.session.state.achievements[this.name] != null);
  }

  earn(elapsed) {
    if (elapsed == null) { elapsed = this.game.elapsedStartMillis(); }
    if (!this.isEarned()) {
      this.game.withUnreifiedSave(() => {
        return this.game.session.state.achievements[this.name] = elapsed;
      });
      return $rootScope.$emit('achieve', this);
    }
  }

  earnedAtMillisElapsed() {
    return this.game.session.state.achievements[this.name];
  }

  earnedAtMoment() {
    if ((this.isEarned() == null)) {
      return undefined;
    }
    const ret = moment(this.game.session.state.date.started);
    ret.add(this.game.session.state.achievements[this.name], 'ms');
    return ret;
  }

  pointsEarned() {
    if (this.isEarned()) { return this.type.points; } else { return 0; }
  }

  // invisible achievements are masked with ???s. TODO support truly hidden achievements
  isMasked() { return !this.isUnmasked(); }
  isUnmasked() {
    // special case: no requirements specified == forever-masked
    // (if you'd like always-visible, a visibility of meat:0 works)
    if (this.visible.length === 0) {
      return false;
    }
    for (var visible of Array.from(this.visible)) {
      if (visible.resource.count().lessThan(visible.val)) {
        return false;
      }
    }
    return true;
  }

  hasProgress() {
    for (var req of Array.from(this.requires)) {
      if (req.resource != null) {
        return true;
      }
    }
    return false;
  }
  progressMax() {
    if ((this.hasProgress() != null) && (this.requires[0].val != null)) {
      return new Decimal(this.requires[0].val);
    }
  }
  progressVal() {
    const req = this.requires[0];
    if (req.upgrade != null) {
      return req.upgrade.count();
    }
    if (req.unit != null) {
      let left;
      if (req.unit.unittype.unbuyable) {
        return req.unit.count();
      }
      return new Decimal((left = req.unit.statistics().twinnum) != null ? left : 0);
    }
    return undefined;
  }
  progressPercent() {
    if (this.hasProgress() != null) {
      return this.progressVal().dividedBy(this.progressMax());
    }
  }
  progressOrder() {
    if (this.isEarned()) {
      return 2;
    }
    if (this.isMasked()) {
      return -2;
    }
    if (this.hasProgress() && (this.progressMax() > 0)) {
      return this.progressPercent().toNumber();
    }
    return -1;
  }
};
 });

angular.module('swarmApp').factory('AchievementTypes', function(spreadsheetUtil, util, $log) { let AchievementTypes;
return AchievementTypes = class AchievementTypes {
  constructor() {
    this.list = [];
    this.byName = {};
  }

  register(achievement) {
    this.list.push(achievement);
    return this.byName[achievement.name] = achievement;
  }

  pointsPossible() {
    return util.sum(_.map(this.list, a => a.points));
  }

  static parseSpreadsheet(data, unittypes, upgradetypes) {
    let row;
    const rows = spreadsheetUtil.parseRows({name:['requires', 'visible']}, data.data.achievements.elements);
    const ret = new AchievementTypes();
    for (row of Array.from(rows)) {
      ret.register(row);
    }
    for (row of Array.from(ret.list)) {
      spreadsheetUtil.resolveList(row.requires, 'unittype', unittypes.byName, {required:false});
      spreadsheetUtil.resolveList(row.requires, 'upgradetype', upgradetypes.byName, {required:false});
      spreadsheetUtil.resolveList(row.visible, 'unittype', unittypes.byName, {required:false});
      spreadsheetUtil.resolveList(row.visible, 'upgradetype', upgradetypes.byName, {required:false});
      util.assert(row.points >= 0, 'achievement must have points', row.name, row);
      util.assert(_.isNumber(row.points), 'achievement points must be number', row.name, row);
    }
    return ret;
  }
};
 });

angular.module('swarmApp').factory('AchievementsListener', function(util, $log) { let AchievementsListener;
return AchievementsListener = class AchievementsListener {
  constructor(game, scope) {
    this.game = game;
    this.scope = scope;
    this._listen(this.scope);
  }

  achieveUnit(unitname, rawcount) {
    // actually checks all units
    if (rawcount == null) { rawcount = false; }
    return Array.from(this.game.achievementlist()).map((achieve) =>
      (() => {
        const result = [];
        for (var require of Array.from(achieve.requires)) {
        // unit count achievement
          if (!require.event && require.unit && require.val) {
            var count;
            if (rawcount) {
              // exceptional case, count all units, ignoring statistics
              count = require.unit.count();
            } else {
              // usually we want to ignore generators, so use statistics-count
              // statistics are added before achievement-check, fortunately
              var left;
              count = (left = require.unit.statistics().twinnum) != null ? left : 0;
              count = new Decimal(count);
            }
            $log.debug('achievement check: unitcount after command', require.unit.name, count+'', (count != null) && (count >= require.val));
            if ((count != null) && count.greaterThanOrEqualTo(require.val)) {
              $log.debug('earned', achieve.name, achieve);
              // requirements are 'or'ed
              result.push(achieve.earn());
            } else {
              result.push(undefined);
            }
          } else {
            result.push(undefined);
          }
        }
        return result;
      })());
  }
  achieveUpgrade(upgradename) {
    // actually checks all upgrades
    return Array.from(this.game.achievementlist()).map((achieve) =>
      (() => {
        const result = [];
        for (var require of Array.from(achieve.requires)) {
          if (!require.event && require.upgrade && require.val) {
            // no upgrade-generators, so count() is safe
            var count = require.upgrade.count();
            $log.debug('achievement check: upgradecount after command', require.upgrade.name, count, (count != null) && (count >= require.val));
            if ((count != null) && count.greaterThanOrEqualTo(require.val)) {
              $log.debug('earned', achieve.name, achieve);
              // requirements are 'or'ed
              result.push(achieve.earn());
            } else {
              result.push(undefined);
            }
          } else {
            result.push(undefined);
          }
        }
        return result;
      })());
  }

  _listen(scope) {
    this.scope = scope;
    for (var achieve of Array.from(this.game.achievementlist())) { (achieve => {
      return (() => {
        const result = [];
        for (var require of Array.from(achieve.requires)) {
          if (require.event && !require.unit) { result.push((require => {
            // trigger event once achievement
            let cancelListen;
            if (require.val) {
              require.val = JSON.parse(require.val);
              $log.debug('parse event-achievement json', require.event, require.val);
            }
            return cancelListen = this.scope.$on(require.event, (event, param) => {
              $log.debug('achieve listen', require.event, param, require.val);
              if (require.val) {
                // very simple equality validation
                const validparam = _.pick(param, _.keys(require.val));
                const valid = _.isEqual(validparam, require.val);
                $log.debug('validate', require.event, require.val, validparam, valid);
                if (!valid) {
                  return;
                }
              }
              return achieve.earn();
            });
          })(require)); } else {
            result.push(undefined);
          }
        }
        return result;
      })();
    })(achieve); }
            // TODO rebuild this on reset
            //cancelListen()

    return this.scope.$on('command', (event, cmd) => {
      $log.debug('checking achievements for command', cmd);
      if (cmd.unitname != null) {
        this.achieveUnit(cmd.unitname);
      }
      if (cmd.upgradename != null) {
        this.achieveUpgrade(cmd.upgradename);
      }
      if (cmd.name === 'ascension') {
        $log.debug('ascending!', this.game.unit('ascension').count());
        return this.achieveUnit('ascension', true);
      }
    });
  }
};
 });

angular.module('swarmApp').factory('achievementslistener', (AchievementsListener, game, $rootScope) => new AchievementsListener(game, $rootScope));

/**
 * @ngdoc service
 * @name swarmApp.achievements
 * @description
 * # achievements
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('achievements', (AchievementTypes, unittypes, upgradetypes, spreadsheet) => AchievementTypes.parseSpreadsheet(spreadsheet, unittypes, upgradetypes));
