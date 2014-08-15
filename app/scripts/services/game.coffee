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
      @_producerPathList = _.map @unittype.producerPathList, (path) =>
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

    _producerPathData: ->
      _.map @_producerPathList, (path) =>
        tailpath = path.concat [this]
        _.map path, (parent, index) =>
          child = tailpath[index+1]
          # TODO index prod by name?
          prodlink = (prod for prod in parent.prod when prod.unit.name == child.name)
          console.assert prodlink.length == 1
          prodlink = prodlink[0]
          parent:parent
          child:child
          prod:prod

    rawCount: ->
      @game.session.unittypes[@name] ? 0
    _setCount: (val) ->
      @game.session.unittypes[@name] = val
    _addCount: (val) ->
      @game.session.unittypes[@name] = @rawCount() + val
    _subtractCount: (val) ->
      @_addCount -val

    _gainsPath: (pathdata, secs) ->
      producerdata = pathdata[0]
      gen = pathdata.length
      c = math.factorial gen
      count = producerdata.parent.rawCount()
      # Bonus for ancestor to produced-child == product of all bonuses along the path
      # (intuitively, if velocity and velocity-changes are doubled, acceleration is doubled too)
      # Quantity of buildings along the path do not matter, they're calculated separately.
      bonus = 1
      for ancestordata in pathdata
        bonus *= ancestordata.prod.val
      return count * bonus / c * math.pow secs, gen

    count: (secs=@game.diffSeconds()) ->
      gains = @rawCount()
      for pname, pathdata of @_producerPathData()
        gains += @_gainsPath pathdata, secs
      return gains

    _costMetPercent: ->
      max = Number.MAX_VALUE
      for cost in @cost
        if cost.val > 0
          max = Math.min max, cost.unit.count() / cost.val
          #console.log 'maxcostmet', @name, cost.unit.name, cost.unit.count(), cost.val, cost.unit.count()/cost.val, max
      console.assert max >= 0, "invalid max", max
      return max

    isVisible: ->
      # this is all needlessly complicated, but I don't wanna specify visibility requirements for every unit and having them all visible at the beginning is lame
      if @unittype.disabled
        return false
      if @_visible
        return true
      return @_visible = @_isVisible()

    _isVisible: ->
      if @count() > 0
        return true
      if @cost.length > 0
        # units with cost are visible at some percentage of the cost, OR when one of their immediate children exist (ex. 1 drone makes queens visible, but not nests)
        if @_costMetPercent() > 0.3
          return true
        for prod in @prod
          if prod.unit.count() >= 5 #arbitrary
            return true
        return false
      else
        # costless units (ex. territory) - any producers visible?
        for path in @_producerPathList
          producer = path[0]
          if producer.isVisible()
            return true
        return false

    maxCostMet: ->
      Math.floor @_costMetPercent()

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
      num = Math.min num, @maxCostMet()
      @game.reify()
      for cost in @cost
        cost.unit._subtractCount cost.val * num
      @_addCount num
      @game.session.save()

    totalProduction: ->
      ret = {}
      count = @count()
      for prod in @prod
        ret[prod.unit.unittype.name] = Math.ceil count * prod.val
      return ret

  return class Game
    constructor: (@session) ->
      @_units = _.mapValues unittypes.byName, (unittype, name) =>
        new Unit this, unittype
      for name, unit of @_units
        unit._initProducerPath()
      @_unitlist = _.map unittypes.list, (unittype) =>
        @_units[unittype.name]
      @tick()

    diffMillis: ->
      @now.getTime() - @session.date.reified.getTime()

    diffSeconds: ->
      @diffMillis() / 1000

    tick: (now=new Date()) ->
      @now = now

    unit: (unitname) ->
      if not _.isString unitname
        # it's a unittype?
        unitname = unitname.name
      @_units[unitname]

    units: ->
      _.clone @_units
    unitlist: ->
      _.clone @_unitlist

    # TODO deprecated, remove in favor of unit(name).count(secs)
    count: (unitname, secs) ->
      return @unit(unitname).count secs

    counts: (secs) ->
      _.mapValues @units(), (unit, name) =>
        unit.count secs

    # Store the 'real' counts, and the time last counted, in the session.
    # Usually, counts are calculated as a function of last-reified-count and time,
    # see count().
    # You must reify before making any changes to unit counts or effectiveness!
    # (So, units that increase the effectiveness of other units AND are produced
    # by other units - ex. derivative clicker mathematicians - can't be supported.)
    reify: ->
      secs = @diffSeconds()
      counts = @counts secs
      _.extend @session.unittypes, counts
      @session.date.reified = @now
      console.assert 0 == @diffSeconds()

    save: ->
      @reify()
      @session.save()

    reset: ->
      @session.reset()
      for unit in @unitlist()
        unit._setCount unit.unittype.init
      @save()

angular.module('swarmApp').factory 'game', (Game, session, env) ->
  game = new Game session
  try
    session.load()
    console.log 'Game data loaded successfully.', this
  catch
    if env != 'test' # too noisy in test
      console.warn 'Failed to load saved data! Resetting.'
    game.reset()
  return game
