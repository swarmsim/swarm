'use strict'

angular.module('swarmApp').factory 'Effect', (util) -> class Effect
  constructor: (@game, @parent, data) ->
    _.extend this, data
    if data.unittype?
      @unit = util.assert @game.unit data.unittype
    if data.unittype2?
      @unit2 = util.assert @game.unit data.unittype2

  onBuy: ->
    @type.onBuy? this, @game, @parent

  calcStats: (stats={}, schema={}, level=@parent.count()) ->
    @type.calcStats? this, stats, schema, level
    return stats

  bank: -> @type.bank? this, @game
  cap: -> @type.cap? this, @game
  output: -> @type.output? this, @game


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

angular.module('swarmApp').factory 'effecttypes', (EffectType, EffectTypes, util) ->
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
      effect.val
  effecttypes.register
    name: 'addUnitByVelocity'
    onBuy: (effect, game) ->
      effect.unit._addCount @output effect, game
    output: (effect, game) ->
      effect.unit.velocity() * effect.val
  effecttypes.register
    name: 'compoundUnit'
    bank: (effect, game) ->
      base = effect.unit.count()
      if effect.unit2?
        base += effect.unit2.count()
      return base
    cap: (effect, game) ->
      if effect.val2 == '' or not effect.val2?
        return undefined
      velocity = effect.unit.velocity()
      if effect.unit2?
        velocity += effect.unit2.velocity()
      return effect.val2 * velocity
    output: (effect, game) ->
      base = @bank effect, game
      ret = base * (effect.val - 1)
      if (cap = @cap effect, game)?
        ret = Math.min ret, cap
      return ret
    onBuy: (effect, game) ->
      effect.unit._addCount @output effect, game
  effecttypes.register
    name: 'applyBuff'
    onBuy: (effect) ->
      # TODO type
      duration = moment.duration effect.val, 'seconds'
      effect.game.applyBuff 'testtype', duration
    output: (effect) ->
      1

  effecttypes.register
    name: 'multStat'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'mult'
      stats[effect.stat] ?= 1
      stats[effect.stat] *= Math.pow effect.val, level
  effecttypes.register
    name: 'asympStat'
    calcStats: (effect, stats, schema, level) ->
      # val: asymptote max; val2: 1/x weight
      # asymptote min: 1, max: effect.val
      validateSchema effect.stat, schema, 'mult' # this isn't multstat, but it's commutative with it
      weight = level * effect.val2
      util.assert weight >= 0, 'negative asympStat weight'
      stats[effect.stat] ?= 1
      stats[effect.stat] *= 1 + (effect.val-1) * (1 - 1 / (1 + weight))
  effecttypes.register
    name: 'addStat'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'add'
      stats[effect.stat] ?= 0
      stats[effect.stat] += effect.val * level
  effecttypes.register
    name: 'multStatPerAchievementPoint'
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'mult'
      points = effect.game.achievementPoints()
      stats[effect.stat] ?= 1
      stats[effect.stat] *= Math.pow 1 + effect.val * points, level
  effecttypes.register
    name: 'suffix'
    calcStats: (effect, stats, schema, level) ->
      # using calcstats for this is so hacky....
      if level == 0
        suffix = ''
      else
        suffix = ROMANNUM[level] ? num + 1
      effect.unit.suffix = suffix
      stats.empower ?= 0
      stats.empower += level
  return effecttypes
