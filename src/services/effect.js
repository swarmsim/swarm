/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';
import _ from 'lodash';

angular.module('swarmApp').factory('Effect', function(util) { let Effect;
return Effect = class Effect {
  constructor(game, parent, data) {
    this.game = game;
    this.parent = parent;
    _.extend(this, data);
    if (data.unittype != null) {
      this.unit = util.assert(this.game.unit(data.unittype));
    }
    if (data.unittype2 != null) {
      this.unit2 = util.assert(this.game.unit(data.unittype2));
    }
    if (data.upgradetype != null) {
      this.upgrade = util.assert(this.game.upgrade(data.upgradetype));
    }
  }
  parentUnit() {
    // parent can be a unit or an upgrade
    if (this.parent.unittype != null) { return this.parent; } else { return this.parent.unit; }
  }
  parentUpgrade() {
    if (this.parent.unittype != null) { return null; } else { return this.parent; }
  }
  hasParentStat(statname, _default) {
    return this.parentUnit().hasStat(statname, _default);
  }
  parentStat(statname, _default) {
    return this.parentUnit().stat(statname, _default);
  }

  onBuy(level) {
    return (typeof this.type.onBuy === 'function' ? this.type.onBuy(this, this.game, this.parent, level) : undefined);
  }
  onBuyUnit(twinnum) {
    return (typeof this.type.onBuyUnit === 'function' ? this.type.onBuyUnit(this, this.game, this.parent, twinnum) : undefined);
  }

  calcStats(stats, schema, level) {
    if (stats == null) { stats = {}; }
    if (schema == null) { schema = {}; }
    if (level == null) { level = this.parent.count(); }
    if (typeof this.type.calcStats === 'function') {
      this.type.calcStats(this, stats, schema, level);
    }
    return stats;
  }

  bank() { return (typeof this.type.bank === 'function' ? this.type.bank(this, this.game) : undefined); }
  cap() { return (typeof this.type.cap === 'function' ? this.type.cap(this, this.game) : undefined); }
  output(level) { return (typeof this.type.output === 'function' ? this.type.output(this, this.game, undefined, level) : undefined); }
  outputNext() { return this.output(this.parent.count().plus(1)); }
  power() {
    let ret = this.parentStat('power', 1);
    // include, for example, "power.swarmwarp"
    const upname = __guard__(this.parentUpgrade(), x => x.name);
    if (upname) {
      ret = ret.times(this.parentStat(`power.${upname}`, 1));
    }
    return ret;
  }
};
 });

angular.module('swarmApp').factory('EffectType', function() { let EffectType;
return (EffectType = class EffectType {
  constructor(data) {
    _.extend(this, data);
  }
});
 });

/**
 * @ngdoc service
 * @name swarmApp.effect
 * @description
 * # effect
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('EffectTypes', function() { let EffectTypes;
return (EffectTypes = class EffectTypes {
  constructor(effecttypes) {
    if (effecttypes == null) { effecttypes = []; }
    this.list = [];
    this.byName = {};
    for (var effecttype of Array.from(effecttypes)) {
      this.register(effecttype);
    }
  }

  register(effecttype) {
    this.list.push(effecttype);
    this.byName[effecttype.name] = effecttype;
    return this;
  }
});
 });

angular.module('swarmApp').factory('romanize', function() {
  // romanize() from http://blog.stevenlevithan.com/archives/javascript-roman-numeral-converter
  // MIT licensed, according to a comment from the author - safe to copy here
  // coffeelint: disable=no_backticks
  
  const romanize = function(num) {
    if (!+num)
      return false;
    let digits = String(+num).split(""),
        key = ["","C","CC","CCC","CD","D","DC","DCC","DCCC","CM",
               "","X","XX","XXX","XL","L","LX","LXX","LXXX","XC",
               "","I","II","III","IV","V","VI","VII","VIII","IX"],
        roman = "",
        i = 3;
    while (i--)
      roman = (key[+digits.pop() + (i * 10)] || "") + roman;
    return Array(+digits.join("") + 1).join("M") + roman;
  };
  // coffeelint: enable=no_backticks
  return romanize;
});

angular.module('swarmApp').factory('effecttypes', function(EffectType, EffectTypes, util, seedrand, $log, romanize) {
  const ONE = new Decimal(1);

  const effecttypes = new EffectTypes();
  // Can't write functions in our spreadsheet :(
  // TODO: move this to upgrade parsing. this only asserts at runtime if a conflict happens, we want it to assert at loadtime
  const validateSchema = function(stat, schema, operation) {
    if (schema[stat] == null) { schema[stat] = operation; }
    return util.assert(schema[stat] === operation, `conflicting stat operations. expected ${operation}, got ${schema[stat]}`, stat, schema, operation);
  };
  effecttypes.register({
    name: 'addUnit',
    onBuy(effect, game) {
      return effect.unit._addCount(this.output(effect, game));
    },
    onBuyUnit(effect, game, boughtUnit, num) {
      return effect.unit._addCount(this.output(effect, game, num));
    },
    output(effect, game, num) {
      if (num == null) { num = 1; }
      return effect.power().times(effect.val).times(num);
    }
  });
  effecttypes.register({
    name: 'addUnitByVelocity',
    onBuy(effect, game) {
      return effect.unit._addCount(this.output(effect, game));
    },
    output(effect, game) {
      return effect.unit.velocity().times(effect.val).times(effect.power());
    }
  });
  effecttypes.register({
    name: 'addUnitTimed',
    onBuy(effect, game, parent, level) {
      const thresholdMillis = effect.val2 * 1000;
      if ((effect.unit2 == null) || effect.unit2.isVisible()) {
        if (effect.unit.isAddUnitTimerReady(thresholdMillis)) {
          // TODO this should be @output
          effect.unit._addCount(effect.val);
          return effect.unit.setAddUnitTimer();
        }
      }
    }
  });
  effecttypes.register({
    name: 'addUnitRand',
    onBuy(effect, game, parent, level) {
      const out = this.output(effect, game, parent, level);
      if (out.spawned) {
        if (effect.unit.count().isZero()) {
          // first spawn. Show tutorial text, this session only. This is totally hacky.
          game.cache.firstSpawn[effect.unit.name] = game.now;
        }
        return effect.unit._addCount(out.qty);
      }
    },
    output(effect, game, parent, level) {
      // minimum level needed to spawn units. Also, guarantees a spawn at exactly this level.
      let baseqty, qty;
      if (parent == null) { ({
        parent
      } = effect); }
      if (level == null) { level = parent.count(); }
      const minlevel = effect.parentStat(`random.minlevel.${parent.name}`);
      if (level.greaterThanOrEqualTo(minlevel)) {
        const stat_each = effect.parentStat('random.each', 1);
        // chance of any unit spawning at all. base chance set in spreadsheet with statinit.
        const prob = effect.parentStat('random.freq');
        // quantity of units spawned, if any spawn at all.
        const minqty = 0.9;
        const maxqty = 1.1;
        const qtyfactor = effect.val;
        baseqty = stat_each.times(Decimal.pow(qtyfactor, level));
        // consistent random seed. No savestate scumming.
        if (game.session.state.date.restarted == null) { game.session.state.date.restarted = game.session.state.date.started; }
        const seed = `[${game.session.state.date.restarted.getTime()}, ${effect.parent.name}, ${level}]`;
        const rng = seedrand.rng(seed);
        // at exactly minlevel, a free spawn is guaranteed, no random roll
        // guarantee a spawn every 8 levels too, so people don't get long streaks of bad rolls
        // TODO: remove the 8-levels guaranteed spawns, inspect previous spawns to look for failing streaks and increase odds based on that.
        const roll = rng();
        const isspawned = level.equals(minlevel) || level.modulo(8).equals(0) || new Decimal(roll+'').lessThan(prob);
        //$log.debug 'roll to spawn: ', level, roll, prob, isspawned
        const roll2 = rng();
        const modqty = minqty + (roll2 * (maxqty - minqty));
        // toPrecision: decimal.js insists on this precision, and it'll parse the string output.
        // decimal.js would rather we use Decimal.random(), but we can't seed that.
        qty = baseqty.times(modqty+'').ceil();
        //$log.debug 'spawned. roll for quantity: ', {level:level, roll:roll2, modqty:modqty, baseqty:baseqty, qtyfactor:qtyfactor, qty:qty, stat_each:stat_each}
        return {spawned:isspawned, baseqty, qty};
      }
      return {spawned:false, baseqty:new Decimal(0), qty:new Decimal(0)};
    }
  });
  effecttypes.register({
    name: 'compoundUnit',
    bank(effect, game) {
      let base = effect.unit.count();
      if (effect.unit2 != null) {
        base = base.plus(effect.unit2.count());
      }
      return base;
    },
    cap(effect, game) {
      // empty, not zero
      if ((effect.val2 === '') || (effect.val2 == null)) {
        return undefined;
      }
      let velocity = effect.unit.velocity();
      if (effect.unit2 != null) {
        velocity = velocity.plus(effect.unit2.velocity());
      }
      return velocity.times(effect.val2).times(effect.power());
    },
    output(effect, game) {
      let cap;
      const base = this.bank(effect, game);
      let ret = base.times(effect.val - 1);
      if ((cap = this.cap(effect, game)) != null) {
        ret = Decimal.min(ret, cap);
      }
      return ret;
    },
    onBuy(effect, game) {
      return effect.unit._addCount(this.output(effect, game));
    }
  });
  effecttypes.register({
    name: 'addUpgrade',
    onBuy(effect, game) {
      return effect.upgrade._addCount(this.output(effect, game));
    },
    output(effect, game) {
      return effect.power().times(effect.val);
    }
  });
  effecttypes.register({
    name: 'skipTime',
    onBuy(effect) {
      return effect.game.skipTime(this.output(effect).toNumber(), 'seconds');
    },
    output(effect) {
      return effect.power().times(effect.val);
    }
  });

  effecttypes.register({
    name: 'multStat',
    calcStats(effect, stats, schema, level) {
      validateSchema(effect.stat, schema, 'mult');
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : ONE).times(Decimal.pow(effect.val, level));
    }
  });
  effecttypes.register({
    name: 'expStat',
    calcStats(effect, stats, schema, level) {
      validateSchema(effect.stat, schema, 'mult');
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : ONE).times(Decimal.pow(level, effect.val).times(effect.val2).plus(1));
    }
  });
  effecttypes.register({
    name: 'asympStat',
    calcStats(effect, stats, schema, level) {
      // val: asymptote max; val2: 1/x weight
      // asymptote min: 1, max: effect.val
      validateSchema(effect.stat, schema, 'mult'); // this isn't multstat, but it's commutative with it
      const weight = level.times(effect.val2);
      util.assert(!weight.isNegative(), 'negative asympStat weight');
      //stats[effect.stat] *= 1 + (effect.val-1) * (1 - 1 / (1 + weight))
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : ONE).times(ONE.plus((new Decimal(effect.val).minus(1)).times(ONE.minus(ONE.dividedBy(weight.plus(1))))));
    }
  });
  effecttypes.register({
    name: 'logStat',
    calcStats(effect, stats, schema, level) {
      // val: log multiplier; val2: log base
      // minimum value is 1.
      validateSchema(effect.stat, schema, 'mult'); // this isn't multstat, but it's commutative with it
      //stats[effect.stat] *= (effect.val3 ? 1) * (Math.log(effect.val2 + effect.val * level)/Math.log(effect.val2) - 1) + 1
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : ONE).times(new Decimal(effect.val3 != null ? effect.val3 : 1).times(Decimal.log(level.times(effect.val).plus(effect.val2)).dividedBy(Decimal.log(effect.val2)).minus(1)).plus(1));
    }
  });
  effecttypes.register({
    name: 'addStat',
    calcStats(effect, stats, schema, level) {
      validateSchema(effect.stat, schema, 'add');
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : new Decimal(0)).plus(new Decimal(effect.val).times(level));
    }
  });
  // multStat by a constant, level independent
  effecttypes.register({
    name: 'initStat',
    calcStats(effect, stats, schema, level) {
      validateSchema(effect.stat, schema, 'mult');
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : ONE).times(effect.val);
    }
  });
  effecttypes.register({
    name: 'multStatPerAchievementPoint',
    calcStats(effect, stats, schema, level) {
      validateSchema(effect.stat, schema, 'mult');
      const points = effect.game.achievementPoints();
      return stats[effect.stat] = (stats[effect.stat] != null ? stats[effect.stat] : ONE).times(Decimal.pow(ONE.plus(new Decimal(effect.val).times(points)), level));
    }
  });
  effecttypes.register({
    name: 'suffix',
    calcStats(effect, stats, schema, level) {
      // using calcstats for this is so hacky....
      let suffix;
      if (level.isZero()) {
        suffix = '';
      } else if (level.lessThan(3999)) {
        // should be safe to assume suffix levels are below 1e308
        suffix = romanize(level.plus(1).toNumber());
      }
      if ((suffix == null)) {
        // romanize lists a bunch of Ms past this point; just use regular numbers instead
        suffix = level.plus(1).toString();
      }
      effect.unit.suffix = suffix;
      return stats.empower = (stats.empower != null ? stats.empower : new Decimal(0)).plus(level);
    }
  });
  return effecttypes;
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}