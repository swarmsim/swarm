'use strict'

###*
 # @ngdoc service
 # @name swarmApp.unittypes
 # @description
 # # unittypes
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'UnitType', -> class Unit
  constructor: (data) ->
    _.extend this, data

  producerNames: ->
    _.mapValues @producerPath, (path) ->
      _.pluck path, 'name'

angular.module('swarmApp').factory 'UnitTypes', (spreadsheetUtil, UnitType) -> class UnitTypes
  constructor: (unittypes=[]) ->
    @list = []
    @byName = {}
    for unittype in unittypes
      @register unittype

  register: (unittype) ->
    @list.push unittype
    @byName[unittype.name] = unittype

  @_buildProducerPath = (unittype, producer, path) ->
    path = [producer].concat path
    unittype.producerPath[producer.name] = path
    for nextgen in producer.producedBy
      @_buildProducerPath unittype, nextgen, path

  @parseSpreadsheet: (data) ->
    rows = spreadsheetUtil.parseRows {name:['cost','prod']}, data.data.unittypes.elements
    ret = new UnitTypes (new UnitType(row) for row in rows)
    for unittype in ret.list
      unittype.producedBy = []
    for unittype in ret.list
      #unittype.tick = if unittype.tick then moment.duration unittype.tick else null
      #unittype.cooldown = if unittype.cooldown then moment.duration unittype.cooldown else null
      # replace names with refs
      for cost in unittype.cost
        name = cost.unittype
        cost.unittype = ret.byName[name]
        console.assert cost.unittype, "invalid cost unittype ref: #{unittype.name} #{name}", name, cost, unittype
      for prod in unittype.prod
        name = prod.unittype
        prod.unittype = ret.byName[name]
        console.assert prod.unittype, "invalid prod unittype ref: #{unittype.name} #{name}", name, cost, unittype
        prod.unittype.producedBy.push unittype
    for unittype in ret.list
      unittype.producerPath = {}
      for producer in unittype.producedBy
        @_buildProducerPath unittype, producer, []
    #console.log 'built unittypes', ret
    return ret

###*
 # @ngdoc service
 # @name swarmApp.units
 # @description
 # # units
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'unittypes', (UnitTypes, spreadsheet) ->
  return UnitTypes.parseSpreadsheet spreadsheet
