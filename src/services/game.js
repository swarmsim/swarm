/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';
import _ from 'lodash';

angular.module('swarmApp').factory('Cache', function() { let Cache;
return (Cache = class Cache {
  constructor() {
    // Never cleared; hacky way to pass messages that get cleared on reload
    this.firstSpawn = {};
    this.onUpdate();
    this.onRespec();
  }

  onPeriodic() {
    this._lastPeriodicClear = new Date().getTime();
    this.upgradeIsUpgradable = {};
    return this.upgradeEstimateSecsUntilBuyablePeriodic = {};
  }

  onUpdate() {
    this.onPeriodic();
    this.onTick();
    this.tinyUrl = {};
    this.stats = {};
    this.eachCost = {};
    this.eachProduction = {};
    this.upgradeTotalCost = {};
    this.producerPathProdEach = {};
    this.producerPathCoefficients = {};
    this.unitRawCount = {};
    this.unitCap = {};
    this.unitCapPercent = {};
    return this.upgradeEstimateSecsUntilBuyableCacheSafe = {};
  }

  onTick() {
    this.unitCount = {};
    this.velocity = {};
    this.totalProduction = {};
    this.upgradeMaxCostMet = {};
    this.unitMaxCostMet = {};
    this.unitMaxCostMetOfVelocity = {};
    delete this.tutorialStep;

    // clear periodic caches every few seconds
    if ((new Date().getTime() - this._lastPeriodicClear) >= 3000) {
      return this.onPeriodic();
    }
  }

  onRespec() {
    this.unitVisible = {};
    return this.upgradeVisible = {};
  }
}); });

/**
 * @ngdoc service
 * @name swarmApp.game
 * @description
 * # game
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('Game', function(unittypes, upgradetypes, achievements, util, $log, Upgrade, Unit, Achievement, Tab, Cache) { let Game;
return Game = (function() {
  Game = class Game {
    static initClass() {
      this.prototype.respecCostRate = 0.3;
    }
    constructor(session) {
      this.session = session;
      this._init();
    }
    _init() {
      let item;
      this._units = {
        list: _.map(unittypes.list, unittype => {
          return new Unit(this, unittype);
        })
      };
      this._units.byName = _.keyBy(this._units.list, 'name');
      this._units.bySlug = _.keyBy(this._units.list, u => u.unittype.slug);

      this._upgrades = {
        list: _.map(upgradetypes.list, upgradetype => {
          return new Upgrade(this, upgradetype);
        })
      };
      this._upgrades.byName = _.keyBy(this._upgrades.list, 'name');

      this._achievements = {
        list: _.map(achievements.list, achievementtype => {
          return new Achievement(this, achievementtype);
        })
      };
      this._achievements.byName = _.keyBy(this._achievements.list, 'name');
      this.achievementPointsPossible = achievements.pointsPossible();
      $log.debug('possiblepoints: ', this.achievementPointsPossible);

      this.tabs = Tab.buildTabs(this._units.list);

      this.skippedMillis = 0;
      this.gameSpeed = 1;
      if (this.session.state.skippedMillis == null) { this.session.state.skippedMillis = 0; }

      for (item of Array.from([].concat(this._units.list, this._upgrades.list, this._achievements.list))) {
        item._init();
      }
      for (item of Array.from(this._units.list)) {
        item._init2();
      }

      this.cache = new Cache();

      // tick to reified-time, then to now. this ensures things explode here, instead of later, if they've gone back in time since saving
      delete this.now;
      this.tick(__guard__(__guard__(this.session != null ? this.session.state : undefined, x1 => x1.date), x => x.reified));
      return this.tick();
    }

    diffMillis() {
      return (this._realDiffMillis() * this.gameSpeed) + this.skippedMillis;
    }
    _realDiffMillis() {
      const ret = this.now.getTime() - this.session.state.date.reified.getTime();
      return Math.max(0, ret);
    }
    diffSeconds() {
      return this.diffMillis() / 1000;
    }

    skipMillis(millis) {
      millis = Math.floor(millis);
      this.skippedMillis += millis;
      return this.session.state.skippedMillis += millis;
    }
    skipDuration(duration) {
      return this.skipMillis(duration.asMilliseconds());
    }
    skipTime(...args) {
      return this.skipDuration(moment.duration(...Array.from(args || [])));
    }

    setGameSpeed(speed) {
      this.reify();
      return this.gameSpeed = speed;
    }

    totalSkippedMillis() {
      return this.session.state.skippedMillis;
    }
    totalSkippedDuration() {
      return moment.duration(this.totalSkippedMillis());
    }
    dateStarted() {
      return this.session.state.date.started;
    }
    momentStarted() {
      return moment(this.dateStarted());
    }

    tick(now, skipExpire) {
      if (now == null) { now = new Date(); }
      if (skipExpire == null) { skipExpire = false; }
      util.assert(now, "can't tick to undefined time", now);
      if ((!this.now) || (this.now <= now)) {
        this.now = now;
        return this.cache.onTick();
      } else {
        // system clock problem! don't whine for small timing errors, but don't update the clock either.
        // TODO I hope this accounts for DST
        const diffMillis = this.now.getTime() - now.getTime();
        return util.assert(diffMillis <= (120 * 1000), "tick tried to go back in time. System clock problem?", this.now, now, diffMillis);
      }
    }

    elapsedStartMillis() {
      return this.now.getTime() - this.session.state.date.started.getTime();
    }
    timestampMillis() {
      return this.elapsedStartMillis() + this.totalSkippedMillis();
    }

    unit(unitname) {
      if (_.isUndefined(unitname)) {
        return undefined;
      }
      if (!_.isString(unitname)) {
        // it's a unittype?
        unitname = unitname.name;
      }
      return this._units.byName[unitname];
    }
    unitBySlug(unitslug) {
      if (unitslug) {
        return this._units.bySlug[unitslug];
      }
    }
    units() {
      return _.clone(this._units.byName);
    }
    unitlist() {
      return _.clone(this._units.list);
    }

    // TODO deprecated, remove in favor of unit(name).count(secs)
    count(unitname, secs) {
      return this.unit(unitname).count(secs);
    }

    counts() { return this.countUnits(); }
    countUnits() {
      return _.mapValues(this.units(), (unit, name) => unit.count());
    }
    countUpgrades() {
      return _.mapValues(this.upgrades(), (upgrade, name) => upgrade.count());
    }
    getNewlyUpgradableUnits() {
      return (() => {
        const result = [];
        for (var u of Array.from(this.unitlist())) {           if (u.isNewlyUpgradable() && u.isVisible()) {
            result.push(u);
          }
        }
        return result;
      })();
    }

    upgrade(name) {
      if (!_.isString(name)) {
        ({
          name
        } = name);
      }
      return this._upgrades.byName[name];
    }
    upgrades() {
      return _.clone(this._upgrades.byName);
    }
    upgradelist() {
      return _.clone(this._upgrades.list);
    }
    availableUpgrades(costPercent) {
      if (costPercent == null) { costPercent = undefined; }
      return (() => {
        const result = [];
        for (var u of Array.from(this.upgradelist())) {           if (u.isVisible() && u.isUpgradable(costPercent, true)) {
            result.push(u);
          }
        }
        return result;
      })();
    }
    availableAutobuyUpgrades(costPercent) {
      if (costPercent == null) { costPercent = undefined; }
      return (() => {
        const result = [];
        for (var u of Array.from(this.availableUpgrades(costPercent))) {           if (u.isAutobuyable()) {
            result.push(u);
          }
        }
        return result;
      })();
    }
    ignoredUpgrades() {
      return (() => {
        const result = [];
        for (var u of Array.from(this.upgradelist())) {           if (u.isVisible() && u.isIgnored()) {
            result.push(u);
          }
        }
        return result;
      })();
    }
    unignoredUpgrades() {
      return (() => {
        const result = [];
        for (var u of Array.from(this.upgradelist())) {           if (u.isVisible() && !u.isIgnored()) {
            result.push(u);
          }
        }
        return result;
      })();
    }

    resourcelist() {
      return this.unitlist().concat(this.upgradelist());
    }

    achievement(name) {
      if (!_.isString(name)) {
        ({
          name
        } = name);
      }
      return this._achievements.byName[name];
    }
    achievements() {
      return _.clone(this._achievements.byName);
    }
    achievementlist() {
      return _.clone(this._achievements.list);
    }
    achievementsSorted() {
      return _.sortBy(this.achievementlist(), a => a.earnedAtMillisElapsed());
    }
    achievementPoints() {
      return util.sum(_.map(this.achievementlist(), a => a.pointsEarned()));
    }
    achievementPercent() {
      return this.achievementPoints() / this.achievementPointsPossible;
    }

    // Store the 'real' counts, and the time last counted, in the session.
    // Usually, counts are calculated as a function of last-reified-count and time,
    // see count().
    // You must reify before making any changes to unit counts or effectiveness!
    // (So, units that increase the effectiveness of other units AND are produced
    // by other units - ex. derivative clicker mathematicians - can't be supported.)
    reify(skipSeconds) {
      if (skipSeconds == null) { skipSeconds = 0; }
      const secs = this.diffSeconds();
      const counts = this.counts(secs);
      _.extend(this.session.state.unittypes, counts);
      this.skippedMillis = 0;
      this.session.state.skippedMillis += this.diffMillis() - this._realDiffMillis();
      this.session.state.date.reified = this.now;
      this.cache.onUpdate();
      return util.assert(0 === this.diffSeconds(), 'diffseconds != 0 after reify!');
    }

    save() {
      return this.withSave(function() {});
    }

    importSave(encoded, transient) {
      this.session.importSave(encoded, transient);
      // Force-clear various caches.
      return this._init();
    }

    // A common pattern: change something (reifying first), then save the changes.
    // Use game.withSave(myFunctionThatChangesSomething) to do that.
    withSave(fn) {
      this.reify();
      const ret = fn();
      // reify a second time for swarmwarp; https://github.com/erosson/swarm/issues/241
      // Unnecessary for other things, but mostly harmless.
      this.reify();
      this.session.save();
      this.cache.onUpdate();
      return ret;
    }

    withUnreifiedSave(fn) {
      const ret = fn();
      this.session.save();
      return ret;
    }

    reset(transient) {
      if (transient == null) { transient = false; }
      this.session.reset();
      this._init();
      for (var unit of Array.from(this.unitlist())) {
        unit._setCount(unit.unittype.init || 0);
      }
      if (!transient) {
        return this.save();
      }
    }

    ascendEnergySpent() {
      const energy = this.unit('energy');
      return energy.spent();
    }
    ascendCost(opts) {
      let spent;
      if (opts == null) { opts = {}; }
      if (opts.spent != null) {
        spent = new Decimal(opts.spent);
      } else {
        spent = this.ascendEnergySpent();
      }
      const ascends = this.unit('ascension').count();
      const ascendPenalty = Decimal.pow(1.12, ascends);
      //return Math.ceil 999999 / (1 + spent/50000)
      // initial cost 5 million, halved every 50k spent, increases 20% per past ascension
      const costVelocity = new Decimal(50000).times(this.unit('mutagen').stat('ascendCost', 1));
      return ascendPenalty.times(5e6).dividedBy(Decimal.pow(2, spent.dividedBy(costVelocity))).ceil();
    }
    ascendCostCapDiff(cost) {
      if (cost == null) { cost = this.ascendCost(); }
      return cost.minus(this.unit('energy').capValue());
    }
    ascendCostPercent(cost) {
      if (cost == null) { cost = this.ascendCost(); }
      return Decimal.min(1, this.unit('energy').count().dividedBy(cost));
    }
    ascendCostDurationSecs(cost) {
      if (cost == null) { cost = this.ascendCost(); }
      const energy = this.unit('energy');
      if (cost.lessThan(energy.capValue())) {
        return energy.estimateSecsUntilEarned(cost).toNumber();
      }
    }
    ascendCostDurationMoment(cost) {
      let secs;
      if ((secs=this.ascendCostDurationSecs(cost)) != null) {
        return moment.duration(secs, 'seconds');
      }
    }
    ascend(free) {
      if (free == null) { free = false; }
      if (!free && (this.ascendCostPercent() < 1)) {
        throw new Error("We require more resources (ascension cost)");
      }
      return this.withSave(() => {
        // hardcode ascension bonuses. TODO: spreadsheetify
        let unit;
        const premutagen = this.unit('premutagen');
        const mutagen = this.unit('mutagen');
        const ascension = this.unit('ascension');
        mutagen._addCount(premutagen.count());
        premutagen._setCount(0);
        ascension._addCount(1);
        this.session.state.date.restarted = this.now;
        // grant a free respec every 3 ascensions
        if (ascension.count().modulo(3).isZero()) {
          this.unit('freeRespec')._addCount(1);
        }
        // do not use @reset(): we don't want achievements, etc. reset
        this._init();
        // show tutorial message for first ascension. must go after @_init, or cache is cleared
        if (ascension.count().equals(1)) {
          this.cache.firstSpawn.ascension = true;
        }
        for (unit of Array.from(this.unitlist())) {
          if (!unit.unittype.ascendPreserve) {
            unit._setCount(unit.unittype.init || 0);
          }
        }
        return (() => {
          const result = [];
          for (var upgrade of Array.from(this.upgradelist())) {
            if ((upgrade.unit.tab != null ? upgrade.unit.tab.name : undefined) !== 'mutagen') {
              result.push(upgrade._setCount(0));
            } else {
              result.push(undefined);
            }
          }
          return result;
        })();
      });
    }

    respecRate() {
      return 1.00;
    }
    respecCost() {
      return this.ascendCost().times(this.respecCostRate).ceil();
    }
    respecCostCapDiff() { return this.ascendCostCapDiff(this.respecCost()); }
    respecCostPercent() { return this.ascendCostPercent(this.respecCost()); }
    respecCostDurationSecs() { return this.ascendCostDurationSecs(this.respecCost()); }
    respecCostDurationMoment() { return this.ascendCostDurationMoment(this.respecCost()); }
    isRespecCostMet() {
      return this.unit('energy').count().greaterThanOrEqualTo(this.respecCost());
    }
    respecSpent() {
      const mutagen = this.unit('mutagen');
      // upgrade costs are weird - upgrade costs rely on other upgrades, which breaks spending tracking.
      // ignore them, relying on the mutateHidden upgrade for the true cost.
      const ignores = {};
      for (var up of Array.from(mutagen.upgrades.list)) {
        ignores[up.name] = true;
      }
      // Upgrades come with a free(ish) unit too, so remove their cost. (Mostly for unit tests, doesn't really matter.)
      return mutagen.spent(ignores).minus(this.upgrade('mutatehidden').count());
    }
    respec() {
      return this.withSave(() => {
        if (!this.isRespecCostMet()) {
          throw new Error("We require more resources");
        }
        const cost = this.respecCost();
        this.unit('energy')._subtractCount(cost);
        // respeccing wipes spent-energy. energy cost of respeccing counts toward spent-energy *after* spent-energy is wiped
        const spent = this.ascendEnergySpent().minus(cost);
        this.unit('respecEnergy')._addCount(spent);
        return this._respec();
      });
    }

    respecFree() {
      return this.withSave(() => {
        if (!this.unit('freeRespec').count().greaterThan(0)) {
          throw new Error("We require more resources");
        }
        this.unit('freeRespec')._subtractCount(1);
        return this._respec();
      });
    }

    _respec() {
      const mutagen = this.unit('mutagen');
      const spent = this.respecSpent();
      for (var resource of Array.from(mutagen.spentResources())) {
        resource._setCount(0);
      }
      mutagen._addCount(spent.times(this.respecRate()).floor());
      this.cache.onRespec();
      return util.assert(mutagen.spent().isZero(), "respec didn't refund all mutagen!");
    }
  };
  Game.initClass();
  return Game;
})();
 });

angular.module('swarmApp').factory('game', (Game, session) => new Game(session));

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}