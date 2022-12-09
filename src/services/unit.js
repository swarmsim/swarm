/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';
import _ from 'lodash';
import * as math from '@bower_components/mathjs';

angular.module('swarmApp').factory('ProducerPath', function($log, UNIT_LIMIT) { let ProducerPath;
return ProducerPath = class ProducerPath {
  constructor(unit, path) {
    this.unit = unit;
    this.path = path;
    const pathname = _.map(this.path, p => p.parent.name).join('>');
    // unit.name's in the name twice, just so there's no confusion about where the path ends
    this.name = `${this.unit.name}:${pathname}>${this.unit.name}`;
  }
  first() { return this.path[0]; }
  isZero() { return this.first().parent.count().isZero(); }
  degree() { return this.path.length; }
  degreeOrZero() { if (this.isZero()) { return 0; } else { return this.degree(); } }
  prodEach() {
    return this.unit.game.cache.producerPathProdEach[this.name] != null ? this.unit.game.cache.producerPathProdEach[this.name] : (this.unit.game.cache.producerPathProdEach[this.name] = (() => {
      // Bonus for ancestor to produced-child == product of all bonuses along the path
      // (intuitively, if velocity and velocity-changes are doubled, acceleration is doubled too)
      // Quantity of buildings along the path do not matter, they're calculated separately.
      let ret = new Decimal(1);
      for (var ancestordata of Array.from(this.path)) {
        var val = new Decimal(ancestordata.prod.val).plus(ancestordata.parent.stat('base', 0));
        ret = ret.times(val);
        ret = ret.times(ancestordata.parent.stat('prod', 1));
        // Cap ret, just like count(). This prevents Infinity * 0 = NaN problems, too.
        ret = Decimal.min(ret, UNIT_LIMIT);
      }
      return ret;
    })());
  }
  coefficient(count) {
    // floor(): no fractional units. #184
    if (count == null) { count = this.first().parent.rawCount(); }
    return count.floor().times(this.prodEach());
  }
  coefficientNow() {
    return this.coefficient(this.first().parent.count());
  }
  count(secs) {
    const degree = this.degree();
    const coeff = this.coefficient();
    // c * (t^d)/d!
    return coeff.times(Decimal.pow(secs, degree)).dividedBy(math.factorial(degree));
  }
};
 });

angular.module('swarmApp').factory('ProducerPaths', function($log, ProducerPath) { let ProducerPaths;
return ProducerPaths = class ProducerPaths {
  constructor(unit, raw) {
    this.unit = unit;
    this.raw = raw;
    this.list = _.map(this.raw, path => {
      const tailpath = path.concat([this.unit]);
      return new ProducerPath(this.unit, _.map(path, (parent, index) => {
        const child = tailpath[index+1];
        const prodlink = parent.prodByName[child.name];
        return {
          parent,
          child,
          prod:prodlink
        };
      })
      );
    });
    this.byDegree = _.groupBy(this.list, path => path.degree());
  }

  getDegreeCoefficient(degree, now) {
    if (now == null) { now = false; }
    let ret = new Decimal(0);
    for (var path of Array.from(this.byDegree[degree] != null ? this.byDegree[degree] : [])) {
      ret = ret.plus(now ? path.coefficientNow() : path.coefficient());
    }
    return ret;
  }

  // Highest polynomial degree of this unit's production chain where the ancestor has nonzero count.
  // Or, how many parents it has. Examples of degree:
  //
  // [drone] is degree 0 (constant, rawcount() with no time factor)
  // [drone > meat] is degree 1
  // [queen > drone > meat] is degree 2
  // [nest > queen > drone > meat] is degree 3
  // [nest > queen > drone] is degree 2
  getMaxDegree() {
    return this.getCoefficients().length - 1;
  }

  getCoefficients() {
    return this.unit.game.cache.producerPathCoefficients[this.unit.name] != null ? this.unit.game.cache.producerPathCoefficients[this.unit.name] : (this.unit.game.cache.producerPathCoefficients[this.unit.name] = this._getCoefficients());
  }

  _getCoefficients(now) {
    // array indexes are polynomial degrees, values are coefficients
    // [1, 3, 5, 7] = 7t^3 + 5t^2 + 3t + 1
    let degree;
    if (now == null) { now = false; }
    const ret = [now ? this.unit.count() : this.unit.rawCount()];
    for (var pathdata of Array.from(this.list)) {
      degree = pathdata.degree();
      var coefficient = now ? pathdata.coefficientNow() : pathdata.coefficient();
      if (!coefficient.isZero()) {
        ret[degree] = (ret[degree] != null ? ret[degree] : new Decimal(0)).plus(coefficient);
      }
    }
    for (degree = 0; degree < ret.length; degree++) {
      var coeff = ret[degree];
      if ((coeff == null)) {
        ret[degree] = new Decimal(0);
      }
    }
    return ret;
  }

  getCoefficientsNow() {
    return this._getCoefficients(true);
  }
  
  count(secs) {
    // Horner's method should be faster here:
    // https://en.wikipedia.org/wiki/Horner's_method
    // http://jsbin.com/doqudoxopo/edit?html,output
    // ...but I tried it and it wasn't.
    let ret = new Decimal(0);
    const iterable = this.getCoefficients();
    for (let degree = 0; degree < iterable.length; degree++) {
      // c * (t^d)/d!
      var coeff = iterable[degree];
      ret = ret.plus(coeff.times(Decimal.pow(secs, degree)).dividedBy(math.factorial(degree)));
    }
    return ret;
  }
};
 });

angular.module('swarmApp').factory('Unit', function(util, $log, Effect, ProducerPaths, UNIT_LIMIT) { let Unit;
return Unit = (function() {
  Unit = class Unit {
    static initClass() {
  
      this.ESTIMATE_BISECTION = true;
    }
    // TODO unit.unittype is needlessly long, rename to unit.type
    constructor(game, unittype) {
      this.game = game;
      this.unittype = unittype;
      this.name = this.unittype.name;
      this.suffix = '';
      this.affectedBy = [];
      this.type = this.unittype; // start transitioning now
    }
    _init() {
      this.prod = _.map(this.unittype.prod, prod => {
        const ret = _.clone(prod);
        ret.unit = this.game.unit(prod.unittype);
        ret.val = new Decimal(ret.val);
        return ret;
      });
      this.prodByName = _.keyBy(this.prod, prod => prod.unit.name);
      this.cost = _.map(this.unittype.cost, cost => {
        const ret = _.clone(cost);
        ret.unit = this.game.unit(cost.unittype);
        ret.val = new Decimal(ret.val);
        return ret;
      });
      this.costByName = _.keyBy(this.cost, cost => cost.unit.name);
      this.warnfirst = _.map(this.unittype.warnfirst, warnfirst => {
        const ret = _.clone(warnfirst);
        ret.unit = this.game.unit(warnfirst.unittype);
        return ret;
      });
      this.showparent = this.game.unit(this.unittype.showparent);
      this.upgrades =
        {list: ((Array.from(this.game.upgradelist()).filter((upgrade) => (this.unittype === upgrade.type.unittype) || ((this.showparent != null ? this.showparent.unittype : undefined) === upgrade.type.unittype))))};
      this.upgrades.byName = _.keyBy(this.upgrades.list, 'name');
      this.upgrades.byClass = _.groupBy(this.upgrades.list, u => u.type.class);

      this.requires = _.map(this.unittype.requires, require => {
        util.assert(require.unittype || require.upgradetype, 'unit require without a unittype or upgradetype', this.name, name, require);
        util.assert(!(require.unittype && require.upgradetype), 'unit require with both unittype and upgradetype', this.name, name, require);
        const ret = _.clone(require);
        ret.val = new Decimal(ret.val);
        if (require.unittype != null) {
          ret.resource = (ret.unit = util.assert(this.game.unit(require.unittype)));
        }
        if (require.upgradetype != null) {
          ret.resource = (ret.upgrade = util.assert(this.game.upgrade(require.upgradetype)));
        }
        return ret;
      });
      this.cap = _.map(this.unittype.cap, capspec => {
        const ret = _.clone(capspec);
        ret.unit = this.game.unit(ret.unittype);
        ret.val = new Decimal(ret.val);
        return ret;
      });
      this.effect = _.map(this.unittype.effect, effect => {
        const ret = new Effect(this.game, this, effect);
        ret.unit.affectedBy.push(ret);
        return ret;
      });

      this.tab = this.game.tabs.byName[this.unittype.tab];
      if (this.tab) {
        this.next = this.tab.next(this);
        return this.prev = this.tab.prev(this);
      }
    }
    // hacky, but we need two stages of init() for our object graph: all unit->unittype, all prod->unit, all producerpath->prod
    _init2() {
      // copy all the inter-unittype references, replacing the type references with units
      return this._producerPath = new ProducerPaths(this, _.map(this.unittype.producerPathList, path => {
        return _.map(path, unittype => {
          const ret = this.game.unit(unittype);
          util.assert(ret);
          return ret;
        });
      })
      );
    }

    isCountInitialized() {
      return (this.game.session.state.unittypes[this.name] != null);
    }
    rawCount() {
      return this.game.cache.unitRawCount[this.name] != null ? this.game.cache.unitRawCount[this.name] : (this.game.cache.unitRawCount[this.name] = (() => {
        // caching's helpful to avoid re-parsing session strings
        let ret = this.game.session.state.unittypes[this.name] != null ? this.game.session.state.unittypes[this.name] : 0;
        if (_.isNaN(ret)) {
          util.error('NaN count. oops.', this.name, ret);
          ret = 0;
        }
        // toPrecision avoids Decimal errors when converting old saves
        if (_.isNumber(ret)) {
          ret = ret.toPrecision(15);
        }
        return new Decimal(ret);
      })());
    }
    _setCount(val) {
      this.game.session.state.unittypes[this.name] = new Decimal(val);
      return this.game.cache.onUpdate();
    }
    _addCount(val) {
      return this._setCount(this.rawCount().plus(val));
    }
    _subtractCount(val) {
      return this._addCount(new Decimal(val).times(-1));
    }

    // direct parents, not grandparents/etc. Drone is parent of meat; queen is parent of drone; queen is not parent of meat.
    _parents() {
      return (() => {
        const result = [];
        for (var pathdata of Array.from(this._producerPath.list)) {           if (pathdata.first().parent.prodByName[this.name]) {
            result.push(pathdata.first().parent);
          }
        }
        return result;
      })();
    }

    _getCap() {
      return this.game.cache.unitCap[this.name] != null ? this.game.cache.unitCap[this.name] : (this.game.cache.unitCap[this.name] = (() => {
        if (this.hasStat('capBase')) {
          let ret = this.stat('capBase');
          ret = ret.times(this.stat('capMult', 1));
          ret = ret.plus(this.stat('capFlat', 0));
          return ret;
        }
      })());
    }
    capValue(val) {
      const cap = this._getCap();
      if ((cap == null)) {
        // if both are undefined, prefer undefined to NaN, mostly for legacy
        if ((val == null)) {
          return val;
        }
        return Decimal.min(val, UNIT_LIMIT);
      }
      if ((val == null)) {
        // no value supplied - return just the cap
        return cap;
      }
      return Decimal.min(val, cap);
    }

    capPercent() {
      let cap;
      if ((cap = this.capValue()) != null) {
        return this.count().dividedBy(cap);
      }
    }
    capDurationSeconds() {
      let cap;
      if ((cap = this.capValue()) != null) {
        let left;
        return (left = __guardMethod__(this.estimateSecsUntilEarned(cap), 'toNumber', o => o.toNumber())) != null ? left : 0;
      }
    }
    capDurationMoment() {
      let secs;
      if ((secs = this.capDurationSeconds()) != null) {
        return moment.duration(secs, 'seconds');
      }
    }
    isEstimateExact() {
      // Bisection estimates are precise enough to not say "or less" next to, too.
      return (this._producerPath.getMaxDegree() <= 2) || this.constructor.ESTIMATE_BISECTION;
    }
    isEstimateCacheable() {
      // Bisection estimates are precise enough to cache. 50 iterations is quick and covers estimates up to like 10 years.
      return (this._producerPath.getMaxDegree() <= 2) || this.constructor.ESTIMATE_BISECTION;
    }
    estimateSecsUntilEarned(num) {
      const count = this.count();
      num = new Decimal(num);
      const remaining = num.minus(count);
      if (remaining.lessThanOrEqualTo(0)) {
        return 0;
      }
      const degree = this._producerPath.getMaxDegree();
      //$log.debug 'estimating degree', degree
      const coeffs = this._producerPath.getCoefficientsNow();
      let ret = new Decimal(Infinity);
      if (degree > 0) {
        // TODO this is exact, don't clear the cache periodically
        let linear;
        if (!coeffs[1].isZero()) {
          linear = (ret = Decimal.min(ret, remaining.dividedBy(coeffs[1])));
        }
          //$log.debug 'linear estimate', ret+''
        if (degree > 1) {
          // quadratic formula: (-b +/- (b^2 - 4ac)^0.5) / 2a
          // TODO this is exact, don't clear the cache periodically
          let [__, b, a] = Array.from(coeffs);
          if (!a.isZero()) {
            const c = remaining.negated();
            a = a.dividedBy(2); // for the "/2!" in "c * t^2/2!"
            // a > 0, b >= 0, c < 0: `root` is always positive/non-imaginary, and + is the correct choice for +/- because - will always be a negative root which doesn't make sense for this problem
            //$log.debug 'quadratic: ', a+'', b+'', c+''
            const disc = b.times(b).minus(a.times(c).times(4)).sqrt();
            const quadratic = (ret = Decimal.min(ret, b.negated().plus(disc).dividedBy(a.times(2))));
          }
            //$log.debug 'quadratic estimate', ret+''
            // TODO there's an exact cubic formula, isn't there? implement it.
          if (degree > 2) {
            if (this.constructor.ESTIMATE_BISECTION) {
              // Bisection method - slower/more complex, but more precise
              // if we couldn't pick a starting point, pretend a second's passed and try again, possibly quitting if we finished in a second or less. This basically only happens in unit tests.
              const maxSec = linear != null ? linear : remaining.dividedBy(this._countInSecsFromNow(new Decimal(1)).minus(count));
              if (!maxSec.greaterThan(0)) {
                ret = new Decimal(1);
              } else {
                ret = this.estimateSecsUntilEarnedBisection(num, maxSec);
              }
            } else {
              // Estimate from minimum degree - faster/simpler, but less precise
              // http://www.kongregate.com/forums/4545-swarm-simulator/topics/473244-time-remaining-suggestion?page=1#posts-8985615
              const iterable = coeffs.slice(3);
              for (let i = 0, deg = i; i < iterable.length; i++, deg = i) {
                // remaining (r) = c * (t^d)/d!
                // solve for t: r * d! / c = t^d
                // solve for t: (r * d! / c) ^ (1/d) = t
                var coeff = iterable[deg];
                if (!coeff.isZero()) {
                  //loop starts iterating from 0, not 3. no need to recalculate first few degrees, we did more precise math for them earlier.
                  deg += 3;
                  ret = Decimal.min(ret, remaining.dividedBy(coeff).times(math.factorial(deg)).pow(new Decimal(1).dividedBy(deg)));
                }
              }
            }
          }
        }
      }
                  //$log.debug 'single-degree estimate', deg, ret+''
      //$log.debug 'done estimating', ret.toNumber()
      return ret;
    }

    estimateSecsUntilEarnedBisection(num, origMaxSec) {
      let midSec;
      $log.debug('bisecting');
      // https://en.wikipedia.org/wiki/Bisection_method#Algorithm
      const f = sec => {
        return num.minus(this._countInSecsFromNow(sec));
      };
      const isInThresh = function(min, max) {
        // Different thresholds for different search spaces
        // (We don't care about seconds if the result's in days)
        const thresh = new Decimal(0.2);
        //if min < 60 * 60
        //  thresh = 1
        //else if min < 60 * 60 * 24
        //  thresh = 60
        //else
        //  thresh = 60 * 60
        return max.minus(min).dividedBy(2).lessThan(thresh);
      };

      let minSec = new Decimal(0);
      // No estimates longer than two years, because seriously, why?
      // Because endgame swarmwarps, that's why.
      //maxSec = Decimal.min origMaxSec, 86400 * 365 * 2
      let maxSec = origMaxSec;
      let minVal = f(minSec);
      let maxVal = f(maxSec);
      let iteration = 0;
      const starttime = new Date().getTime();
      let done = false;
      // 40 iterations gives 0.1-second precision for any estimate that starts below 3000 years. Should be plenty.
      // ...swarmwarp demands some damn big iterations. *50* should be plenty.
      while ((iteration < 50) && !done) {
        iteration += 1;
        midSec = maxSec.plus(minSec).dividedBy(2);
        var midVal = f(midSec);
        //$log.debug "bisection estimate: iteration #{iteration}, midsec #{midSec}, midVal #{midVal}"
        if (midVal.isZero() || isInThresh(minSec, maxSec)) {
          done = true;
        } else if ((midVal.isNegative()) === (minVal.isNegative())) {
          minSec = midSec;
          minVal = f(minSec);
        } else {
          maxSec = midSec;
          maxVal = f(maxSec);
        }
      }
      // too many iterations
      const timediff = new Date().getTime() - starttime;
      if (!done) {
        $log.debug(`bisection estimate for ${this.name} took more than ${iteration} iterations; quitting. precision: ${maxSec.minus(minSec).dividedBy(2)} (down from ${origMaxSec}). time: ${timediff}`);
      } else {
        $log.debug(`bisection estimate for ${this.name} finished in ${iteration} iterations. original range: ${origMaxSec}, estimate is ${midSec} - plus game.difftime of ${this.game.diffSeconds()}, that's ${midSec.plus(this.game.diffSeconds())} - this shouldn't change much over multiple iterations. time: ${timediff}`);
      }
      return midSec;
    }

    count() {
      return this.game.cache.unitCount[this.name] != null ? this.game.cache.unitCount[this.name] : (this.game.cache.unitCount[this.name] = this._countInSecsFromNow());
    }

    _countInSecsFromNow(secs) {
      if (secs == null) { secs = new Decimal(0); }
      return this._countInSecsFromReified(secs.plus(this.game.diffSeconds()));
    }
    _countInSecsFromReified(secs) {
      if (secs == null) { secs = 0; }
      return this.capValue(this._producerPath.count(secs));
    }

    // All units that cost this unit.
    spentResources() {
      return (() => {
        const result = [];
        for (var u of Array.from([].concat(this.game.unitlist(), this.game.upgradelist()))) {           if (u.costByName[this.name] != null) {
            result.push(u);
          }
        }
        return result;
      })();
    }
    spent(ignores) {
      let u;
      if (ignores == null) { ignores = {}; }
      let ret = new Decimal(0);
      for (u of Array.from(this.game.unitlist())) {
        var costeach = (u.costByName[this.name] != null ? u.costByName[this.name].val : undefined) != null ? (u.costByName[this.name] != null ? u.costByName[this.name].val : undefined) : 0;
        ret = ret.plus(u.count().times(costeach));
      }
      for (u of Array.from(this.game.upgradelist())) {
        if (u.costByName[this.name] && (ignores[u.name] == null)) {
          // cost for $count upgrades starting from level 1
          var costs = u.sumCost(u.count(), 0);
          var cost = _.find(costs, c => c.unit.name === this.name);
          ret = ret.plus((cost != null ? cost.val : undefined) != null ? (cost != null ? cost.val : undefined) : 0);
        }
      }
      return ret;
    }

    _costMetPercent() {
      let max = new Decimal(Infinity);
      for (var cost of Array.from(this.eachCost())) {
        if (cost.val.greaterThan(0)) {
          max = Decimal.min(max, cost.unit.count().dividedBy(cost.val));
        }
      }
      //util.assert max.greaterThanOrEqualTo(0), "invalid unit cost max", @name
      return max;
    }

    _costMetPercentOfVelocity() {
      let max = new Decimal(Infinity);
      for (var cost of Array.from(this.eachCost())) {
        if (cost.val.greaterThan(0)) {
          max = Decimal.min(max, cost.unit.velocity().dividedBy(cost.val));
        }
      }
      //util.assert max.greaterThanOrEqualTo(0), "invalid unit cost max", @name
      return max;
    }
  
    isVisible() {
      if (this.unittype.disabled) {
        return false;
      }
      if (this.game.cache.unitVisible[this.name]) {
        return true;
      }
      return this.game.cache.unitVisible[this.name] = this._isVisible();
    }

    _isVisible() {
      if (this.count().greaterThan(0)) {
        return true;
      }
      util.assert(this.requires.length > 0, "unit without visibility requirements", this.name);
      for (var require of Array.from(this.requires)) {
        if (require.val.greaterThan(require.resource.count())) {
          if (require.op !== 'OR') { // most requirements are ANDed, any one failure fails them all
            return false;
          }
          // req-not-met for OR requirements: no-op
        } else if (require.op === 'OR') { // single necessary requirement is met
          return true;
        }
      }
      return true;
    }

    isBuyButtonVisible() {
      const eachCost = this.eachCost();
      if (this.unittype.unbuyable || (eachCost.length === 0)) {
        return false;
      }
      for (var cost of Array.from(eachCost)) {
        if (!cost.unit.isVisible()) {
          return false;
        }
      }
      return true;
    }

    maxCostMet(percent) {
      if (percent == null) { percent = 1; }
      return this.game.cache.unitMaxCostMet[`${this.name}:${percent}`] != null ? this.game.cache.unitMaxCostMet[`${this.name}:${percent}`] : (this.game.cache.unitMaxCostMet[`${this.name}:${percent}`] = (() => {
        return this._costMetPercent().times(percent).floor();
      })());
    }
      
    maxCostMetOfVelocity() {
      return this.game.cache.unitMaxCostMetOfVelocity[`${this.name}`] != null ? this.game.cache.unitMaxCostMetOfVelocity[`${this.name}`] : (this.game.cache.unitMaxCostMetOfVelocity[`${this.name}`] = (() => {
        return this._costMetPercentOfVelocity();
      })());
    }
  
    maxCostMetOfVelocityReciprocal() {
      return (new Decimal(1)).dividedBy(this.maxCostMetOfVelocity());
    }

    isCostMet() {
      return this.maxCostMet().greaterThan(0);
    }

    isBuyable(ignoreCost) {
      if (ignoreCost == null) { ignoreCost = false; }
      return (this.isCostMet() || ignoreCost) && this.isBuyButtonVisible() && !this.unittype.unbuyable;
    }

    buyMax(percent) {
      return this.buy(this.maxCostMet(percent));
    }

    twinMult() {
      let ret = new Decimal(1);
      ret = ret.plus(this.stat('twinbase', 0));
      ret = ret.times(this.stat('twin', 1));
      return ret;
    }
    buy(num) {
      if (num == null) { num = 1; }
      if (!this.isCostMet()) {
        throw new Error("We require more resources");
      }
      if (!this.isBuyable()) {
        throw new Error("Cannot buy that unit");
      }
      num = Decimal.min(num, this.maxCostMet());
      return this.game.withSave(() => {
        for (var cost of Array.from(this.eachCost())) {
          cost.unit._subtractCount(cost.val.times(num));
        }
        const twinnum = num.times(this.twinMult());
        this._addCount(twinnum);
        for (var effect of Array.from(this.effect)) {
          effect.onBuyUnit(twinnum);
        }
        // This is a hideous hack that really should be an addUnits effect, but it starts an infinite loop (energy -> mtxEnergy -> energy-cap -> energy...) that I really can't be arsed to debug this late into swarmsim's life.
        if (this.name === 'energy') {
          this.game.unit('mtxEnergy')._addCount(twinnum);
        }
        return {num, twinnum};
    });
    }

    isNewlyUpgradable() {
      const upgrades = __guard__(this.showparent != null ? this.showparent.upgrades : undefined, x => x.list) != null ? __guard__(this.showparent != null ? this.showparent.upgrades : undefined, x => x.list) : this.upgrades.list;
      return _.some(upgrades, upgrade => upgrade.isVisible() && upgrade.isNewlyUpgradable());
    }

    totalProduction() {
      return this.game.cache.totalProduction[this.name] != null ? this.game.cache.totalProduction[this.name] : (this.game.cache.totalProduction[this.name] = (() => {
        const ret = {};
        const count = this.count().floor();
        const object = this.eachProduction();
        for (var key in object) {
          var val = object[key];
          ret[key] = val.times(count);
        }
        return ret;
      })());
    }

    eachProduction() {
      return this.game.cache.eachProduction[this.name] != null ? this.game.cache.eachProduction[this.name] : (this.game.cache.eachProduction[this.name] = (() => {
        const ret = {};
        for (var prod of Array.from(this.prod)) {
          ret[prod.unit.unittype.name] = (prod.val.plus(this.stat('base', 0))).times(this.stat('prod', 1));
        }
        return ret;
      })());
    }

    eachCost() {
      return this.game.cache.eachCost[this.name] != null ? this.game.cache.eachCost[this.name] : (this.game.cache.eachCost[this.name] = _.map(this.cost, cost => {
        cost = _.clone(cost);
        cost.val = cost.val.times(this.stat('cost', 1)).times(this.stat(`cost.${cost.unit.unittype.name}`, 1));
        return cost;
      }));
    }

    // speed at which other units are producing this unit.
    velocity() {
      return this.game.cache.velocity[this.name] != null ? this.game.cache.velocity[this.name] : (this.game.cache.velocity[this.name] = Decimal.min(UNIT_LIMIT, this._producerPath.getDegreeCoefficient(1, true)));
    }

    isVelocityConstant() {
      return this._producerPath.getMaxCoefficient() <= 1;
    }

    // TODO rework this - shouldn't have to pass a default
    hasStat(key, default_) {
      if (default_ == null) { default_ = undefined; }
      return (this.stats()[key] != null) && (this.stats()[key] !== default_);
    }
    stat(key, default_) {
      let left;
      if (default_ == null) { default_ = undefined; }
      util.assert(key != null);
      if (default_ != null) {
        default_ = new Decimal(default_);
      }
      const ret = (left = this.stats()[key]) != null ? left : default_;
      util.assert((ret != null), 'no such stat', this.name, key);
      return new Decimal(ret);
    }
    stats() {
      return this.game.cache.stats[this.name] != null ? this.game.cache.stats[this.name] : (this.game.cache.stats[this.name] = (() => {
        const stats = {};
        const schema = {};
        for (var upgrade of Array.from(this.upgrades.list)) {
          upgrade.calcStats(stats, schema);
        }
        for (var uniteffect of Array.from(this.affectedBy)) {
          uniteffect.calcStats(stats, schema, uniteffect.parent.count());
        }
        return stats;
      })());
    }

    statistics() {
      return __guard__(this.game.session.state.statistics != null ? this.game.session.state.statistics.byUnit : undefined, x => x[this.name]) != null ? __guard__(this.game.session.state.statistics != null ? this.game.session.state.statistics.byUnit : undefined, x => x[this.name]) : {};
    }

    // TODO centralize url handling
    url() {
      return this.tab.url(this);
    }

    // for the addUnitTimed effect
    addUnitTimer() {
      const key = `addUnitTimed-${this.name}`;
      return this.game.session.state.date[key] != null ? this.game.session.state.date[key] : new Date(0);
    }
    addUnitTimerElapsedMillis(now) {
      if (now == null) { ({
        now
      } = this.game); }
      return now.getTime() - this.addUnitTimer().getTime();
    }
    addUnitTimerRemainingMillis(durationMillis, now) {
      if (now == null) { ({
        now
      } = this.game); }
      return Math.max(0, durationMillis - this.addUnitTimerElapsedMillis(now));
    }
    isAddUnitTimerReady(durationMillis, now) {
      if (now == null) { ({
        now
      } = this.game); }
      return this.addUnitTimerRemainingMillis(durationMillis) === 0;
    }
    setAddUnitTimer(now) {
      if (now == null) { ({
        now
      } = this.game); }
      const key = `addUnitTimed-${this.name}`;
      this.game.session.state.date[key] = now;
      return util.assert(this.addUnitTimerElapsedMillis(now) === 0);
    }
  };
  Unit.initClass();
  return Unit;
})();
 });

/**
 * @ngdoc service
 * @name swarmApp.unittypes
 * @description
 * # unittypes
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('UnitType', function() { let Unit;
return Unit = class Unit {
  constructor(data) {
    _.extend(this, data);
    this.producerPath = {};
    this.producerPathList = [];
  }

  producerNames() {
    return _.mapValues(this.producerPath, paths => _.map(paths, path => _.map(path, 'name')));
  }
};
 });

angular.module('swarmApp').factory('UnitTypes', function(spreadsheetUtil, UnitType, util, $log) { let UnitTypes;
return UnitTypes = class UnitTypes {
  constructor(unittypes) {
    if (unittypes == null) { unittypes = []; }
    this.list = [];
    this.byName = {};
    for (var unittype of Array.from(unittypes)) {
      this.register(unittype);
    }
  }

  register(unittype) {
    this.list.push(unittype);
    return this.byName[unittype.name] = unittype;
  }

  static _buildProducerPath(unittype, producer, path) {
    path = [producer].concat(path);
    unittype.producerPathList.push(path);
    if (unittype.producerPath[producer.name] == null) { unittype.producerPath[producer.name] = []; }
    unittype.producerPath[producer.name].push(path);
    return Array.from(producer.producedBy).map((nextgen) =>
      this._buildProducerPath(unittype, nextgen, path));
  }

  static parseSpreadsheet(effecttypes, data) {
    let unittype;
    const rows = spreadsheetUtil.parseRows({name:['cost','prod','warnfirst','requires','cap','effect']}, data.data.unittypes.elements);
    const ret = new UnitTypes((Array.from(rows).map((row) => new UnitType(row))));
    for (unittype of Array.from(ret.list)) {
      unittype.producedBy = [];
      unittype.affectedBy = [];
    }
    for (unittype of Array.from(ret.list)) {
      //unittype.tick = if unittype.tick then moment.duration unittype.tick else null
      //unittype.cooldown = if unittype.cooldown then moment.duration unittype.cooldown else null
      // replace names with refs
      if (unittype.showparent) {
        spreadsheetUtil.resolveList([unittype], 'showparent', ret.byName);
      }
      spreadsheetUtil.resolveList(unittype.cost, 'unittype', ret.byName);
      spreadsheetUtil.resolveList(unittype.prod, 'unittype', ret.byName);
      spreadsheetUtil.resolveList(unittype.warnfirst, 'unittype', ret.byName);
      spreadsheetUtil.resolveList(unittype.requires, 'unittype', ret.byName, {required:false});
      spreadsheetUtil.resolveList(unittype.cap, 'unittype', ret.byName, {required:false});
      spreadsheetUtil.resolveList(unittype.effect, 'unittype', ret.byName);
      spreadsheetUtil.resolveList(unittype.effect, 'type', effecttypes.byName);
      // oops - we haven't parsed upgradetypes yet! done in upgradetype.coffee.
      //spreadsheetUtil.resolveList unittype.require, 'upgradetype', ret.byName
      unittype.slug = unittype.label;
      for (var prod of Array.from(unittype.prod)) {
        prod.unittype.producedBy.push(unittype);
        util.assert(prod.val > 0, "unittype prod.val must be positive", prod);
      }
      for (var cost of Array.from(unittype.cost)) {
        util.assert((cost.val > 0) || (unittype.unbuyable && unittype.disabled), "unittype cost.val must be positive", cost);
      }
    }
    for (unittype of Array.from(ret.list)) {
      for (var producer of Array.from(unittype.producedBy)) {
        this._buildProducerPath(unittype, producer, []);
      }
    }
    $log.debug('built unittypes', ret);
    return ret;
  }
};
 });

/**
 * @ngdoc service
 * @name swarmApp.units
 * @description
 * # units
 * Service in the swarmApp.
*/
angular.module('swarmApp').factory('unittypes', (UnitTypes, effecttypes, spreadsheet) => UnitTypes.parseSpreadsheet(effecttypes, spreadsheet));

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}