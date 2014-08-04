'use strict'

angular.module('swarmApp').factory 'Unit', (dt) -> class Unit
  constructor: (data) ->
    _.extend this, data

  count: (session) ->
    return session.units[@name]

  totalCost: (session) ->
    ret = {}
    count = @count session
    for cost in @cost
      costFactor = Math.pow cost.factor, count
      ret[cost.unit.name] = Math.ceil costFactor * cost.val
    return ret

  totalProduction: (session) ->
    ret = {}
    count = @count session
    for prod in @prod
      ret[prod.unit.name] = Math.ceil count * prod.val
    return ret

  isCostMet: (session) ->
    for name, cost of @totalCost session
      if cost > session.units[name]
        return false
    return true

  buy: (session) ->
    if not @isCostMet session
      throw new Error "We require more resources"
    for name, cost of @totalCost session
      session.units[name] -= cost
    session.units[@name] += 1

  tick: (session) ->
    for name, prod of @totalProduction session
      session.units[name] += prod * dt

angular.module('swarmApp').factory 'Units', (spreadsheetUtil, Unit) -> class Units
  constructor: (units=[]) ->
    @list = []
    @byName = {}
    for unit in units
      @register unit

  register: (unit) ->
    @list.push unit
    @byName[unit.name] = unit

  @parseSpreadsheet: (data) ->
    rows = spreadsheetUtil.parseRows {name:['cost','prod']}, data.data.units.elements
    ret = new Units (new Unit(row) for row in rows)
    for unit in ret.list
      #unit.tick = if unit.tick then moment.duration unit.tick else null
      #unit.cooldown = if unit.cooldown then moment.duration unit.cooldown else null
      # replace names with refs
      for cost in unit.cost
        cost.unit = ret.byName[cost.unit]
        console.assert cost.unit, "invalid cost unit ref: #{unit.name}", unit
      for prod in unit.prod
        prod.unit = ret.byName[prod.unit]
        console.assert prod.unit, "invalid prod unit ref: #{unit.name}", unit
    #console.log 'built units', ret
    return ret

###*
 # @ngdoc service
 # @name swarmApp.units
 # @description
 # # units
 # Service in the swarmApp.
###

angular.module('swarmApp').factory 'units', (Units, spreadsheet) ->
  return spreadsheet.then Units.parseSpreadsheet
