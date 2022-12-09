/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';

/**
 * @ngdoc service
 * @name swarmApp.command
 * @description
 * # command
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('commands', function(util, game, $rootScope, $log, loginApi, mtx) { let Commands;
return new (Commands = class Commands {
  constructor() {}

  _setUndo(opts) {
    if (opts == null) { opts = {}; }
    return this._undo = _.extend({}, opts, {
      state: game.session.exportSave(),
      date: game.now
    }
    );
  }

  undo() {
    if (!(this._undo != null ? this._undo.state : undefined)) {
      throw new Error('no undostate available');
    }
    const {
      state
    } = this._undo;
    this._setUndo({isRedo:true});
    return game.importSave(state, false);
  }

  _emit(name, params) {
    util.assert((params.name == null), 'command has a name already?');
    params.name = name;
    //$rootScope.$emit "command:#{name}", params #this isn't actually used
    $rootScope.$emit("command", params);
    return loginApi.saveCommand(params);
  }

  buyUnit(opts) {
    this._setUndo();
    const {
      unit
    } = opts;
    const {
      num
    } = opts;
    const bought = unit.buy(num);
    return this._emit('buyUnit', {
      unit,
      // names are included for easier jsonification
      unitname:unit.name,
      now:unit.game.now,
      elapsed:unit.game.elapsedStartMillis(),
      attempt:num,
      num:bought.num,
      twinnum:bought.twinnum,
      ui:opts.ui
    }
    );
  }

  buyMaxUnit(opts) {
    this._setUndo();
    const {
      unit
    } = opts;
    const bought = unit.buyMax(opts.percent);
    return this._emit('buyMaxUnit', {
      unit,
      unitname:unit.name,
      now:unit.game.now,
      elapsed:unit.game.elapsedStartMillis(),
      num:bought.num,
      twinnum:bought.twinnum,
      percent:opts.percent,
      ui:opts.ui
    }
    );
  }

  buyUpgrade(opts) {
    this._setUndo();
    const {
      upgrade
    } = opts;
    const num = upgrade.buy(opts.num);
    return this._emit('buyUpgrade', {
      upgrade,
      upgradename:upgrade.name,
      now:upgrade.game.now,
      elapsed:upgrade.game.elapsedStartMillis(),
      num,
      ui:opts.ui
    }
    );
  }

  buyMaxUpgrade(opts) {
    this._setUndo();
    const {
      upgrade
    } = opts;
    const num = upgrade.buyMax(opts.percent);
    return this._emit('buyMaxUpgrade', {
      upgrade,
      upgradename:upgrade.name,
      now:upgrade.game.now,
      elapsed:upgrade.game.elapsedStartMillis(),
      num,
      percent:opts.percent,
      ui:opts.ui
    }
    );
  }

  buyAllUpgrades(opts) {
    this._setUndo();
    const {
      upgrades
    } = opts;
    for (var upgrade of Array.from(upgrades)) {
      var num = upgrade.buyMax(opts.percent / upgrade.watchedDivisor());
      this._emit('buyMaxUpgrade', {
        upgrade,
        upgradename:upgrade.name,
        now:upgrade.game.now,
        elapsed:upgrade.game.elapsedStartMillis(),
        num,
        percent:opts.percent,
        ui:'buyAllUpgrades'
      }
      );
    }
    if (upgrades.length) {
      return this._emit('buyAllUpgrades', {
        now:upgrades[0].game.now,
        elapsed:upgrades[0].game.elapsedStartMillis(),
        percent:opts.percent
      }
      );
    }
  }

  ascend(opts) {
    this._setUndo();
    ({
      game
    } = opts);
    game.ascend();
    return this._emit('ascension', {
      now: game.now,
      unit: game.unit('ascension'),
      unitname: 'ascension',
      num: 1,
      twinnum: 1,
      elapsed: game.elapsedStartMillis()
    }
    );
  }

  respec(opts) {
    this._setUndo();
    ({
      game
    } = opts);
    game.respec();
    return this._emit('respec', {
      now: game.now,
      elapsed: game.elapsedStartMillis()
    }
    );
  }

  respecFree(opts) {
    this._setUndo();
    ({
      game
    } = opts);
    game.respecFree();
    return this._emit('respec', {
      now: game.now,
      elapsed: game.elapsedStartMillis()
    }
    );
  }

  convertCrystal(opts) {
    this._setUndo();
    const {
      conversion
    } = opts;
    mtx.convert(conversion);
    return this._emit('convertEnergy', {
      now: game.now,
      crystal:conversion.crystal,
      energy:conversion.energy
    }
    );
  }
});
 });
