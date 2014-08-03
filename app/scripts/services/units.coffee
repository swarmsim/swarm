'use strict'

angular.module('swarmApp').factory 'Unit', -> class Unit
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
      session.units[name] += prod

###*
 # @ngdoc service
 # @name swarmApp.units
 # @description
 # # units
 # Service in the swarmApp.
###

angular.module('swarmApp').factory 'units', (Unit, spreadsheet) ->
  class Units
    constructor: ->
      @list = []
      @byName = {}
    register: (unit) ->
      @list.push unit
      @byName[unit.name] = unit

  return spreadsheet.then (data, tabletop) ->
    ret = new Units()
    rows = data.data.units.elements
    groups = _.groupBy rows, 'name'
    names = _.uniq _.map rows, 'name'
    console.log 'building units', data, names, groups
    # iterate names intead of groups to preserve order
    for name in names
      group = groups[name]
      mainrow = _.omit group[0], 'cost', 'costunit', 'costfactor', 'prod', 'produnit'
      mainrow.cost = []
      mainrow.prod = []
      for row in group
        console.log 'rowin', row
        if row.cost
          mainrow.cost.push
            val: row.cost
            unit: row.costunit
            factor: row.costfactor
        if row.prod
          mainrow.prod.push
            val: row.prod
            unit: row.produnit
      ret.register new Unit mainrow
    # replace names with refs
    for unit in ret.list
      for cost in unit.cost
        cost.unit = ret.byName[cost.unit]
      for prod in unit.prod
        prod.unit = ret.byName[prod.unit]
    console.log 'built units', ret
    return ret
