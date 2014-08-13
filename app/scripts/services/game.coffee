'use strict'

###*
 # @ngdoc service
 # @name swarmApp.game
 # @description
 # # game
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'Game', (unittypes) ->
  class Unit
    constructor: (@game, @unittype) ->
      @name = @unittype.name
    _initProducerPath: ->
      # copy all the inter-unittype references, replacing the type references with units
      @_producerPath = _.mapValues @unittype.producerPath, (path, pname) =>
        _.map path, (unittype) =>
          ret = @game.unit unittype
          console.assert ret
          return ret
      @cost = _.map @unittype.cost, (cost, name) =>
        console.assert cost.factor == 1, "cost factors not supported anymore"
        ret = _.clone cost
        ret.unit = @game.unit cost.unittype
        return ret
      @prod = _.map @unittype.prod, (prod, name) =>
        ret = _.clone prod
        ret.unit = @game.unit prod.unittype
        return ret

    rawCount: ->
      @game.session.unittypes[@name] ? 0
    _setCount: (val) ->
      @game.session.unittypes[@name] = val
    _addCount: (val) ->
      @game.session.unittypes[@name] = @rawCount() + val

    _gainsPath: (path, secs) ->
      producer = path[0]
      gen = path.length
      c = math.factorial gen
      count = producer.rawCount()
      # Bonus for ancestor to produced-child == product of all bonuses along the path
      # (intuitively, if velocity and velocity-changes are doubled, acceleration is doubled too)
      # Quantity of buildings along the path do not matter, they're calculated separately.
      bonus = 1
      for ancestor in path
        bonus *= 1 # TODO: calculate bonuses
      return count * bonus / c * math.pow secs, gen

    count: (secs=@game.diffSeconds()) ->
      gains = @rawCount()
      for pname, path of @_producerPath
        gains += @_gainsPath path, secs
      return gains

    maxCostMet: ->
      max = Number.MAX_VALUE
      for cost in @cost
        if cost.val > 0
          max = Math.min max, Math.floor cost.unit.count() / cost.val
          #console.log 'maxcostmet', @name, cost.unit.name, cost.unit.count(), cost.val, cost.unit.count()/cost.val, max
      console.assert max >= 0
      return max

    isCostMet: ->
      @maxCostMet() > 0

    isBuyable: ->
      return @isCostMet() and not @unittype.unbuyable and not @unittype.disabled

    buyMax: ->
      @buy @maxCostMet()

    buy: (num=1) ->
      if not @isCostMet()
        throw new Error "We require more resources"
      if not @isBuyable()
        throw new Error "Cannot buy that unit"
      num = Math.min num, maxBuyable
      @game.reify()
      for cost in @cost
        cost.unit._addCount cost.val * num
      @_addCount num
      @session.save()

  return class Game
    constructor: (@session) ->
      @_units = _.mapValues unittypes.byName, (unittype, name) =>
        new Unit this, unittype
      for name, unit of @_units
        unit._initProducerPath()

    diffMillis: (now=new Date()) ->
      now.getTime() - @session.date.reified

    diffSeconds: (now) ->
      @diffMillis(now) / 1000

    unit: (unitname) ->
      if not _.isString unitname
        # it's a unittype?
        unitname = unitname.name
      @_units[unitname]

    units: ->
      _.clone @_units

    # TODO deprecated, remove in favor of unit(name).count(secs)
    count: (unitname, secs) ->
      return @unit(unitname).count secs

    counts: (secs) ->
      _.mapValues units, (unit, name) =>
        unit.count secs

    # Store the 'real' counts, and the time last counted, in the session.
    # Usually, counts are calculated as a function of last-reified-count and time,
    # see count().
    # You must reify before making any changes to unit counts or effectiveness!
    # (So, units that increase the effectiveness of other units AND are produced
    # by other units - ex. derivative clicker mathematicians - can't be supported.)
    reify: (now=new Date()) ->
      secs = @diffSeconds now
      counts = @counts secs
      _.extend @session.unittypes, counts
      @session.date.reified = now
      console.assert 0 == @diffSeconds now

    save: ->
      @reify()
      @session.save()

angular.module('swarmApp').factory 'game', (Game, session) ->
  return new Game session
