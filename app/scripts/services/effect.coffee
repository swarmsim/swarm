'use strict'

angular.module('swarmApp').factory 'Effect', (util) -> class Effect
  constructor: (@game, @parent, data) ->
    _.extend this, data
    if data.unittype?
      @unit = util.assert @game.unit data.unittype
    if data.unittype2?
      @unit2 = util.assert @game.unit data.unittype2
    if data.upgradetype?
      @upgrade = util.assert @game.upgrade data.upgradetype
  parentUnit: ->
    # parent can be a unit or an upgrade
    if @parent.unittype? then @parent else @parent.unit
  parentUpgrade: ->
    if parent.unittype? then null else @parent
  hasParentStat: (statname, _default) ->
    @parentUnit().hasStat statname, _default
  parentStat: (statname, _default) ->
    @parentUnit().stat statname, _default

  onBuy: (level) ->
    @type.onBuy? this, @game, @parent, level

  calcStats: (stats={}, schema={}, level=@parent.count()) ->
    @type.calcStats? this, stats, schema, level
    return stats

  bank: -> @type.bank? this, @game
  cap: -> @type.cap? this, @game
  output: -> @type.output? this, @game
  power: ->
    ret = @parentStat('power', 1)
    # include, for example, "power.swarmwarp"
    upname = @parentUpgrade()?.name
    if upname
      ret = ret.times @parentStat("power.#{upname}", 1)
    return ret

angular.module('swarmApp').factory 'EffectType', -> class EffectType
  constructor: (data) ->
    _.extend this, data

###*
 # @ngdoc service
 # @name swarmApp.effect
 # @description
 # # effect
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'EffectTypes', -> class EffectTypes
  constructor: (effecttypes=[]) ->
    @list = []
    @byName = {}
    for effecttype in effecttypes
      @register effecttype

  register: (effecttype) ->
    @list.push effecttype
    @byName[effecttype.name] = effecttype
    return this

angular.module('swarmApp').factory 'effecttypes', (EffectType, EffectTypes, util, seedrand, $log) ->
  # short hardcoded list, but we don't actually use very high numbers for these
  ROMANNUM = ['', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'
              'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX']
  effecttypes = new EffectTypes()
  # Can't write functions in our spreadsheet :(
  # TODO: move this to upgrade parsing. this only asserts at runtime if a conflict happens, we want it to assert at loadtime
  validateSchema = (stat, schema, operation) ->
    schema[stat] ?= operation
    util.assert schema[stat] == operation, "conflicting stat operations. expected #{operation}, got #{schema[stat]}", stat, schema, operation
  effecttypes.register
    name: 'addUnit'
    onBuy: (effect, game) ->
      effect.unit._addCount @output effect, game
    output: (effect, game) ->
      effect.power().times effect.val
  effecttypes.register
    name: 'addUnitByVelocity'
    onBuy: (effect, game) ->
      effect.unit._addCount @output effect, game
    output: (effect, game) ->
      effect.unit.velocity().times(effect.val).times(effect.power())
  effecttypes.register
    name: 'addUnitRand'
    onBuy: (effect, game, parent, level) ->
      out = @output effect, game, parent, level
      if out.spawned
        effect.unit._addCount out.qty
    output: (effect, game, parent=effect.parent, level=parent.count()) ->
      # minimum level needed to spawn units. Also, guarantees a spawn at exactly this level.
      minlevel = effect.parentStat 'random.minlevel'
      if level.greaterThanOrEqualTo minlevel
        stat_each = effect.parentStat 'random.each', 1
        # chance of any unit spawning at all. base chance set in spreadsheet with statinit.
        prob = effect.parentStat 'random.freq'
        # quantity of units spawned, if any spawn at all.
        minqty = 0.9
        maxqty = 1.1
        qtyfactor = effect.val
        baseqty = stat_each.times Decimal.pow qtyfactor, level
        # consistent random seed. No savestate scumming.
        seed = "[#{effect.parent.name}, #{level}]"
        rng = seedrand.rng seed
        # at exactly minlevel, a free spawn is guaranteed, no random roll
        roll = rng()
        isspawned = level.equals(minlevel) or new Decimal(roll).lessThan(prob.toNumber())
        #$log.debug 'roll to spawn: ', level, roll, prob, isspawned
        roll2 = rng()
        modqty = minqty + (roll2 * (maxqty - minqty))
        qty = Decimal.ceil baseqty.times modqty
        #$log.debug 'spawned. roll for quantity: ', {level:level, roll:roll2, modqty:modqty, baseqty:baseqty, qtyfactor:qtyfactor, qty:qty, stat_each:stat_each}
        return spawned:isspawned, baseqty:baseqty, qty:qty
      return spawned:false, baseqty:new Decimal(0), qty:new Decimal(0)
  effecttypes.register
    name: 'compoundUnit'
    bank: (effect, game) ->
      base = effect.unit.count()
      if effect.unit2?
        base = base.plus effect.unit2.count()
      return base
    cap: (effect, game) ->
      # empty, not zero
      if effect.val2 == '' or not effect.val2?
        return undefined
      velocity = effect.unit.velocity()
      if effect.unit2?
        velocity = velocity.plus effect.unit2.velocity()
      return velocity.times(effect.val2).times(effect.power())
    output: (effect, game) ->
      base = @bank effect, game
      ret = base.times(effect.val - 1)
      if (cap = @cap effect, game)?
        ret = Decimal.min ret, cap
      return ret
    onBuy: (effect, game) ->
      effect.unit._addCount @output effect, game
  effecttypes.register
    name: 'addUpgrade'
    onBuy: (effect, game) ->
      effect.upgrade._addCount @output effect, game
    output: (effect, game) ->
      effect.power().times(effect.val)
  effecttypes.register
    name: 'skipTime'
    onBuy: (effect) ->
      effect.game.skipTime @output(effect).toNumber(), 'seconds'
    output: (effect) ->
      effect.power().times(effect.val)

  effecttypes.register
    name: 'multStat'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'mult'
      stats[effect.stat] = (stats[effect.stat] ? Decimal.ONE).times(Decimal.pow effect.val, level)
  effecttypes.register
    name: 'asympStat'
    calcStats: (effect, stats, schema, level) ->
      # val: asymptote max; val2: 1/x weight
      # asymptote min: 1, max: effect.val
      validateSchema effect.stat, schema, 'mult' # this isn't multstat, but it's commutative with it
      weight = level.times effect.val2
      util.assert not weight.isNegative(), 'negative asympStat weight'
      #stats[effect.stat] *= 1 + (effect.val-1) * (1 - 1 / (1 + weight))
      stats[effect.stat] = (stats[effect.stat] ? Decimal.ONE).plus new Decimal(effect.val).minus(1).times(Decimal.ONE.minus(Decimal.ONE.dividedBy(weight.plus(1))))
  effecttypes.register
    name: 'logStat'
    calcStats: (effect, stats, schema, level) ->
      # val: log multiplier; val2: log base
      # minimum value is 1.
      validateSchema effect.stat, schema, 'mult' # this isn't multstat, but it's commutative with it
      #stats[effect.stat] *= (effect.val3 ? 1) * (Math.log(effect.val2 + effect.val * level)/Math.log(effect.val2) - 1) + 1
      stats[effect.stat] = (stats[effect.stat] ? Decimal.ONE).times(new Decimal(effect.val3 ? 1).times(Decimal.log(level.times(effect.val).plus(effect.val2)).dividedBy(Decimal.log(effect.val2)).minus(1)).plus(1))
  effecttypes.register
    name: 'addStat'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'add'
      stats[effect.stat] = (stats[effect.stat] ? new Decimal 0).plus(new Decimal(effect.val).times level)
  # multStat by a constant, level independent
  effecttypes.register
    name: 'initStat'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'mult'
      stats[effect.stat] = (stats[effect.stat] ? Decimal.ONE).times(effect.val)
  effecttypes.register
    name: 'multStatPerAchievementPoint'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'mult'
      points = effect.game.achievementPoints()
      stats[effect.stat] = (stats[effect.stat] ? Decimal.ONE).times(Decimal.pow Decimal.ONE.plus(effect.val).times(points), level)
  effecttypes.register
    name: 'suffix'
    calcStats: (effect, stats, schema, level) ->
      # using calcstats for this is so hacky....
      if level == 0
        suffix = ''
      else
        suffix = ROMANNUM[level] ? level.plus(1).toString()
      effect.unit.suffix = suffix
      stats.empower = (stats.empower ? new Decimal 0).plus(level)
  return effecttypes
