'use strict'

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
  effecttypes = new EffectTypes()
  # Can't write functions in our spreadsheet :(
  hasUnit = (effect) ->
    util.assert effect.unit?
    util.assert effect.val?
  hasUnitStat = (effect) ->
    util.assert effect.unit?
    util.assert effect.stat?
    util.assert effect.val?
  # TODO: move this to upgrade parsing. this only asserts at runtime if a conflict happens, we want it to assert at loadtime
  validateSchema = (stat, schema, operation) ->
    schema[stat] ?= operation
    util.assert schema[stat] == operation, "conflicting stat operations. expected #{operation}, got #{schema[stat]}", stat, schema, operation
  effecttypes.register new EffectType
    name: 'addUnit'
    validate: hasUnit
    onBuy: (effect, game) ->
      effect.unit._addCount effect.val
  effecttypes.register new EffectType
    name: 'compoundUnit'
    validate: hasUnit
    onBuy: (effect, game) ->
      base = effect.unit.count()
      if effect.unit2?
        base += effect.unit2.count()
      effect.unit._addCount base * (effect.val - 1)
  effecttypes.register new EffectType
    name: 'multStat'
    validate: hasUnitStat
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'mult'
      stats[effect.stat] ?= 1
      stats[effect.stat] *= Math.pow effect.val, level
  effecttypes.register new EffectType
    name: 'addStat'
    validate: hasUnitStat
    calcStats: (effect, stats, schema, level) ->
      validateSchema effect.stat, schema, 'add'
      stats[effect.stat] ?= 0
      stats[effect.stat] += effect.val * level
  return effecttypes
