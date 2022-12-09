/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS202: Simplify dynamic range loops
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';
import _ from 'lodash';

angular.module('swarmApp').factory('Upgrade', function(util, Effect, $log) {
  let Upgrade;
  const ONE = new Decimal(1);

  return Upgrade = class Upgrade {
    constructor(game, type) {
      this.game = game;
      this.type = type;
      this.name = this.type.name;
      this.unit = util.assert(this.game.unit(this.type.unittype));
    }
    _init() {
      this.costByName = {};
      this.cost = _.map(this.type.cost, cost => {
        util.assert(cost.unittype, 'upgrade cost without a unittype', this.name, name, cost);
        const ret = _.clone(cost);
        ret.unit = util.assert(this.game.unit(cost.unittype));
        ret.val = new Decimal(ret.val);
        ret.factor = new Decimal(ret.factor);
        this.costByName[ret.unit.name] = ret;
        return ret;
      });
      this.requires = _.map(this.type.requires, require => {
        util.assert(require.unittype, 'upgrade require without a unittype', this.name, name, require);
        const ret = _.clone(require);
        ret.unit = util.assert(this.game.unit(require.unittype));
        ret.val = new Decimal(ret.val);
        return ret;
      });
      this.effect = _.map(this.type.effect, effect => {
        return new Effect(this.game, this, effect);
      });
      return this.effectByType = _.groupBy(this.effect, 'type.name');
    }
    // TODO refactor counting to share with unit
    count() {
      let ret = this.game.session.state.upgrades[this.name] != null ? this.game.session.state.upgrades[this.name] : 0;
      if (_.isNaN(ret)) {
        util.error(`count is NaN! resetting to zero. ${this.name}`);
        ret = 0;
      }
      // we shouldn't ever exceed maxlevel, but just in case...
      if (this.type.maxlevel) {
        ret = Decimal.min(this.type.maxlevel, ret);
      }
      return new Decimal(ret);
    }
    _setCount(val) {
      this.game.session.state.upgrades[this.name] = new Decimal(val);
      return this.game.cache.onUpdate();
    }
    _addCount(val) {
      return this._setCount(this.count().plus(val));
    }
    _subtractCount(val) {
      return this._addCount(new Decimal(val).negated());
    }
  
    isVisible() {
      // disabled: hack for larvae/showparent. We really need to just remove showparent already...
      if (!this.unit.isVisible() && !this.unit.unittype.disabled) {
        return false;
      }
      if ((this.type.maxlevel != null) && this.count().greaterThanOrEqualTo(this.type.maxlevel)) {
        return false;
      }
      if (this.type.disabled) {
        return false;
      }
      if (this.game.cache.upgradeVisible[this.name]) {
        return true;
      }
      return this.game.cache.upgradeVisible[this.name] = this._isVisible();
    }
    _isVisible() {
      if (this.count().greaterThan(0)) {
        return true;
      }
      for (var require of Array.from(this.requires)) {
        if (require.val.greaterThan(require.unit.count())) {
          return false;
        }
      }
      return true;
    }
    totalCost() {
      return this.game.cache.upgradeTotalCost[this.name] != null ? this.game.cache.upgradeTotalCost[this.name] : (this.game.cache.upgradeTotalCost[this.name] = this._totalCost());
    }
    _totalCost(count) {
      if (count == null) { count = this.count().plus(this.unit.stat('upgradecost', 0)); }
      return _.map(this.cost, cost => {
        const total = _.clone(cost);
        total.val = total.val.times(Decimal.pow(total.factor, count)).times(this.unit.stat("upgradecostmult", 1)).times(this.unit.stat(`upgradecostmult.${this.name}`, 1));
        return total;
      });
    }
    sumCost(num, startCount) {
      return _.map(this._totalCost(startCount), function(cost0) {
        const cost = _.clone(cost0);
        // special case: 1 / (1 - 1) == boom
        if (cost.factor.equals(1)) {
          cost.val = cost.val.times(num);
        } else {
          // see maxCostMet for O(1) summation formula derivation.
          // cost.val *= (1 - Math.pow cost.factor, num) / (1 - cost.factor)
          cost.val = cost.val.times(ONE.minus(Decimal.pow(cost.factor, num)).dividedBy(ONE.minus(cost.factor)));
        }
        return cost;
      });
    }
    isCostMet() {
      return this.maxCostMet().greaterThan(0);
    }
  
    maxCostMet(percent) {
      if (percent == null) { percent = 1; }
      return this.game.cache.upgradeMaxCostMet[`${this.name}:${percent}`] != null ? this.game.cache.upgradeMaxCostMet[`${this.name}:${percent}`] : (this.game.cache.upgradeMaxCostMet[`${this.name}:${percent}`] = (() => {
        // https://en.wikipedia.org/wiki/Geometric_progression#Geometric_series
        //
        // been way too long since my math classes... given from wikipedia:
        // > cost.unit.count = cost.val (1 - cost.factor ^ maxAffordable) / (1 - cost.factor)
        // solve the equation for maxAffordable to get the formula below.
        //
        // This is O(1), but that's totally premature optimization - should really
        // have just brute forced this, we don't have that many upgrades so O(1)
        // math really doesn't matter. Yet I did it anyway. Do as I say, not as I
        // do, kids.
        let cost;
        let max = new Decimal(Infinity);
        if (this.type.maxlevel) {
          max = new Decimal(this.type.maxlevel).minus(this.count());
        }
        for (cost of Array.from(this.totalCost())) {
          var m;
          util.assert(cost.val.greaterThan(0), 'upgrade cost <= 0', this.name, this);
          if (cost.factor.equals(1)) { //special case: math.log(1) == 0; x / math.log(1) == boom
            m = cost.unit.count().dividedBy(cost.val);
          } else {
            //m = Math.log(1 - (cost.unit.count() * percent) * (1 - cost.factor) / cost.val) / Math.log cost.factor
            m = ONE.minus(cost.unit.count().times(percent).times(ONE.minus(cost.factor)).dividedBy(cost.val)).log().dividedBy(cost.factor.log());
          }
          max = Decimal.min(max, m);
        }
          //$log.debug 'iscostmet', @name, cost.unit.name, m, max, cost.unit.count(), cost.val
        // sumCost is sometimes more precise than maxCostMet, leading to buy() breaking - #290.
        // Compare our result here with sumCost, and adjust if precision's a problem.
        max = max.floor();
        if (max.greaterThanOrEqualTo(0)) { // just in case
          for (cost of Array.from(this.sumCost(max))) {
            // maxCostMet is supposed to guarantee we have more units than the cost of this many upgrades!
            // if that's not true, it must be a precision error.
            if (cost.unit.count().lessThan(cost.val)) {
              $log.debug('maxCostMet corrected its own precision');
              return max.minus(1);
            }
          }
        }
        return max;
      })());
    }
  
    isMaxAffordable() {
      return (this.type.maxlevel != null) && this.maxCostMet().greaterThanOrEqualTo(this.type.maxlevel);
    }
  
    costMetPercent() {
      const costOfMet = _.keyBy(this.sumCost(this.maxCostMet()), c => c.unit.name);
      let max = new Decimal(Infinity);
      if (this.isMaxAffordable()) {
        return ONE;
      }
      for (var cost of Array.from(this.sumCost(this.maxCostMet().plus(1)))) {
        var count = cost.unit.count().minus(costOfMet[cost.unit.name].val);
        var val = cost.val.minus(costOfMet[cost.unit.name].val);
        max = Decimal.min(max, (count.dividedBy(val)));
      }
      return Decimal.min(1, Decimal.max(0, max));
    }
  
    estimateSecsUntilBuyable(noRecurse) {
      if (this.isMaxAffordable()) {
        return {val:new Decimal(Infinity)};
      }
      // tricky caching - take the estimated when it was cached, then subtract time that's passed since then.
      let cached = this.game.cache.upgradeEstimateSecsUntilBuyableCacheSafe[this.name];
      if ((cached == null)) {
        cached = this.game.cache.upgradeEstimateSecsUntilBuyablePeriodic[this.name] != null ? this.game.cache.upgradeEstimateSecsUntilBuyablePeriodic[this.name] : (this.game.cache.upgradeEstimateSecsUntilBuyablePeriodic[this.name] = this._estimateSecsUntilBuyable());
        // Some estimates can be cached more permanently (until update)
        if (cached.cacheSafe) {
          this.game.cache.upgradeEstimateSecsUntilBuyableCacheSafe[this.name] = cached;
        }
      }
      let ret = _.extend({val:cached.rawVal.plus((cached.now - this.game.now.getTime())/1000)}, cached);
      // we can now afford the cached upgrade! clear cache, pick another one.
      if (ret.val.lessThanOrEqualTo(0) && !noRecurse) {
        delete this.game.cache.upgradeEstimateSecsUntilBuyableCacheSafe[this.name];
        delete this.game.cache.upgradeEstimateSecsUntilBuyablePeriodic[this.name];
        ret = this.estimateSecsUntilBuyable(true);
      }
      return ret;
    }
      
    _estimateSecsUntilBuyable() {
      const costOfMet = _.keyBy(this.sumCost(this.maxCostMet()), c => c.unit.name);
      let cacheSafe = true;
      let max = {rawVal:new Decimal(0), unit:null};
      if ((this.type.maxlevel != null) && this.maxCostMet().plus(1).greaterThan(this.type.maxlevel)) {
        return 0;
      }
      for (var cost of Array.from(this.sumCost(this.maxCostMet().plus(1)))) {
        var secs = cost.unit.estimateSecsUntilEarned(cost.val);
        if (max.rawVal.lessThan(secs)) {
          max = {rawVal:secs, unit:cost.unit, now: this.game.now.getTime()};
        }
        cacheSafe &= cost.unit.isEstimateCacheable();
      }
      max.cacheSafe = cacheSafe;
      return max;
    }
  
    isUpgradable(costPercent, useWatchedAt) {
      // results are cached and updated only once every few seconds; may be out of date.
      // This function's used for the upgrade-available arrows, and without caching it'd be called once per
      // frame for every upgrade in the game. cpu profiler found it guilty of taking half our cpu when we
      // did that, so the delay's worth it.
      //
      // we could onUpdate-cache true results - false results may change to true at any time, but true
      // results can change to false only at an update. Complexity's not worth it, since true is the less
      // common case (most upgrades are *not* available at any given time). Actually used to do this, but
      // the code got ugly when we added separate periodic caching for falses.
      //
      // we could also predict when an update will be available, instead of rechecking every few seconds,
      // using estimateSecs. Complexity's not worth it yet, but if players start complaining about the
      // caching delay, this would reduce it.
      if (costPercent == null) { costPercent = undefined; }
      if (useWatchedAt == null) { useWatchedAt = false; }
      if (useWatchedAt) {
        costPercent = new Decimal(costPercent != null ? costPercent : 1).dividedBy(this.watchedDivisor());
      }
      return this.game.cache.upgradeIsUpgradable[`${this.name}:${costPercent}`] != null ? this.game.cache.upgradeIsUpgradable[`${this.name}:${costPercent}`] : (this.game.cache.upgradeIsUpgradable[`${this.name}:${costPercent}`] = (this.type.class === 'upgrade') && this.isBuyable() && this.maxCostMet(costPercent).greaterThan(0));
    }
    isAutobuyable() {
      return this.watchedAt() > 0;
    }
    // default should match the default for maxCostMet
    isNewlyUpgradable(costPercent) {
      if (costPercent == null) { costPercent = 1; }
      return (this.watchedAt() > 0) && this.isUpgradable(costPercent / this.watchedDivisor());
    }
  
    // TODO maxCostMet, buyMax that account for costFactor
    isBuyable() {
      return this.isCostMet() && this.isVisible();
    }
  
    buy(num) {
      if (num == null) { num = 1; }
      if (!this.isCostMet()) {
        throw new Error("We require more resources");
      }
      if (!this.isBuyable()) {
        throw new Error("Cannot buy that upgrade");
      }
      num = Decimal.min(num, this.maxCostMet());
      $log.debug('buy', this.name, num);
      return this.game.withSave(() => {
        for (var cost of Array.from(this.sumCost(num))) {
          util.assert(cost.unit.count().greaterThanOrEqualTo(cost.val), "tried to buy more than we can afford. upgrade.maxCostMet is broken!", this.name, name, cost);
          util.assert(cost.val.greaterThan(0), "zero cost from sumCost, yet cost was met?", this.name, name, cost);
          cost.unit._subtractCount(cost.val);
        }
        const count = this.count();
        this._addCount(num);
        // limited to buying less than 1e300 upgrades at once. cost-factors, etc. ensure this is okay.
        // (not to mention 1e300 onBuy()s would take forever)
        for (let i = 0, end = num.toNumber(), asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) {
          for (var effect of Array.from(this.effect)) {
            effect.onBuy(count.plus(i + 1));
          }
        }
        return num;
      });
    }
  
    buyMax(percent) {
      return this.buy(this.maxCostMet(percent));
    }
  
    calcStats(stats, schema) {
      if (stats == null) { stats = {}; }
      if (schema == null) { schema = {}; }
      const count = this.count();
      for (var effect of Array.from(this.effect)) {
        effect.calcStats(stats, schema, count);
      }
      return stats;
    }
  
    statistics() {
      return __guard__(this.game.session.state.statistics != null ? this.game.session.state.statistics.byUpgrade : undefined, x => x[this.name]) != null ? __guard__(this.game.session.state.statistics != null ? this.game.session.state.statistics.byUpgrade : undefined, x => x[this.name]) : {};
    }
  
    _watchedAtDefault() {
      // watch everything by default - except mutagen
      return (this.unit.tab != null ? this.unit.tab.name : undefined) !== 'mutagen';
    }
    isManuallyHidden() {
      return this.watchedAt() < 0;
    }
    watchedAt() {
      if (this.game.session.state.watched == null) { this.game.session.state.watched = {}; }
      const watched = this.game.session.state.watched[this.name] != null ? this.game.session.state.watched[this.name] : this._watchedAtDefault();
      if (typeof(watched) === 'boolean') {
        if (watched) { return 1; } else { return 0; }
      }
      return watched;
    }
    watchedDivisor() {
      return Math.max(this.watchedAt(), 1);
    }
    watch(state) {
      return this.game.withUnreifiedSave(() => {
        if (this.game.session.state.watched == null) { this.game.session.state.watched = {}; }
        // make savestates a little smaller
        if (state !== this._watchedAtDefault()) {
          return this.game.session.state.watched[this.name] = state;
        } else {
          return delete this.game.session.state.watched[this.name];
        }
    });
    }
  };
});

angular.module('swarmApp').factory('UpgradeType', function() { let UpgradeType;
return (UpgradeType = class UpgradeType {
  constructor(data) {
    _.extend(this, data);
  }
});
 });

angular.module('swarmApp').factory('UpgradeTypes', function(spreadsheetUtil, UpgradeType, util) { let UpgradeTypes;
return UpgradeTypes = class UpgradeTypes {
  constructor(unittypes, upgrades) {
    this.unittypes = unittypes;
    if (upgrades == null) { upgrades = []; }
    this.list = [];
    this.byName = {};
    for (var upgrade of Array.from(upgrades)) {
      this.register(upgrade);
    }
  }

  register(upgrade) {
    util.assert(upgrade.name, 'upgrade without a name', upgrade);
    this.list.push(upgrade);
    return this.byName[upgrade.name] = upgrade;
  }

  static parseSpreadsheet(unittypes, effecttypes, data) {
    const rows = spreadsheetUtil.parseRows({name:['requires','cost','effect']}, data.data.upgrades.elements);
    const ret = new UpgradeTypes(unittypes, (Array.from(rows).filter((row) => row.name).map((row) => new UpgradeType(row))));
    for (var upgrade of Array.from(ret.list)) {
      spreadsheetUtil.resolveList([upgrade], 'unittype', unittypes.byName);
      spreadsheetUtil.resolveList(upgrade.cost, 'unittype', unittypes.byName);
      spreadsheetUtil.resolveList(upgrade.requires, 'unittype', unittypes.byName);
      spreadsheetUtil.resolveList(upgrade.effect, 'unittype', unittypes.byName, {required:false});
      spreadsheetUtil.resolveList(upgrade.effect, 'upgradetype', ret.byName, {required:false});
      spreadsheetUtil.resolveList(upgrade.effect, 'type', effecttypes.byName);
      for (var cost of Array.from(upgrade.cost)) {
        util.assert(cost.val > 0, "upgradetype cost.val must be positive", cost);
        if ((upgrade.maxlevel === 1) && !cost.factor) {
          cost.factor = 1;
        }
        util.assert(cost.factor > 0, "upgradetype cost.factor must be positive", cost);
      }
    }
    // resolve unittype.require.upgradetype, since upgrades weren't available when it was parsed. kinda hacky.
    for (var unittype of Array.from(unittypes.list)) {
      spreadsheetUtil.resolveList(unittype.requires, 'upgradetype', ret.byName, {required:false});
    }
    return ret;
  }
};
 });

/**
 * @ngdoc service
 * @name swarmApp.upgrade
 * @description
 * # upgrade
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('upgradetypes', (UpgradeTypes, unittypes, effecttypes, spreadsheet) => UpgradeTypes.parseSpreadsheet(unittypes, effecttypes, spreadsheet));

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}