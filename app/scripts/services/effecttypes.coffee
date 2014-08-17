'use strict'

angular.module('swarmApp').factory 'EffectType', (util) -> class EffectType
  constructor: (data) ->
    _.extend this, data

###*
 # @ngdoc service
 # @name swarmApp.effect
 # @description
 # # effect
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'EffectTypes', (util) -> class EffectTypes
  constructor: (effecttypes=[]) ->
    @list = []
    @byName = {}
    for effecttype in effecttypes
      @register effecttype

  register: (effecttype) ->
    @list.push effecttype
    @byName[effecttype.name] = effecttype
    return this

angular.module('swarmApp').factory 'effecttypes', (EffectType, EffectTypes) ->
  effecttypes = new EffectTypes()
  # Can't write functions in our spreadsheet :(
  hasUnit = (effect) ->
    util.assert effect.unit?
    util.assert effect.val?
  effecttypes.register new EffectType
    name: 'addUnit'
    validate: hasUnit
    onBuy: (effect, game) ->
      effect.unit._addCount effect.val
  effecttypes.register new EffectType
    name: 'compoundUnit'
    validate: hasUnit
    onBuy: (effect, game) ->
      effect.unit._setCount effect.unit.count() * effect.val
  effecttypes.register new EffectType
    name: 'multTwin'
    validate: hasUnit
    onLoad: (effect, game) ->
      throw new Error 'multTwin not yet implemented'
  effecttypes.register new EffectType
    name: 'multProd'
    validate: hasUnit
    onLoad: (effect, game) ->
      throw new Error 'multTwin not yet implemented'
  return effecttypes
