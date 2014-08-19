'use strict'

angular.module('swarmApp').factory 'Effect', (util) -> class Effect
  constructor: (@game, @upgrade, data) ->
    _.extend this, data
    if data.unittype?
      @unit = util.assert @game.unit data.unittype

  onBuy: ->
    @type.onBuy? this, @game, @upgrade

  calcStats: (stats, schema, level) ->
    @type.calcStats? this, stats, schema, level

angular.module('swarmApp').factory 'Upgrade', (util, Effect) -> class Upgrade
  constructor: (@game, @type) ->
    @name = @type.name
    @unit = util.assert @game.unit @type.unittype
    @_totalCost = _.memoize @_totalCost
  _init: ->
    @_cost = _.map @type.cost, (cost) =>
      util.assert cost.unittype, 'upgrade cost without a unittype', @name, name, cost
      ret = _.clone cost
      ret.unit = util.assert @game.unit cost.unittype
      return ret
    @requires = _.map @type.requires, (require) =>
      util.assert require.unittype, 'upgrade require without a unittype', @name, name, require
      ret = _.clone require
      ret.unit = util.assert @game.unit require.unittype
      return ret
    @effect = _.map @type.effect, (effect) =>
      return new Effect @game, this, effect
  # TODO refactor counting to share with unit
  count: ->
    @game.session.upgrades[@name] ? 0
  _setCount: (val) ->
    @game.session.upgrades[@name] = val
    util.clearMemoCache @_totalCost, @unit._stats
  _addCount: (val) ->
    @_setCount @count() + val
  _subtractCount: (val) ->
    @_addCount -val

  isVisible: ->
    if @type.disabled
      return false
    if @_visible
      return true
    return @_visible = @_isVisible()
  _isVisible: ->
    if @count() > 0
      return true
    for require in @requires
      if require.val > require.unit.count()
        return false
    return true
  # TODO refactor cost/buyable to share code with unit?
  totalCost: -> @_totalCost @count()
  _totalCost: (count) ->
    ret = {}
    for cost in @_cost
      total = ret[cost.unit.name] = _.clone cost
      total.val = cost.val * Math.pow cost.factor, count
    return ret
  isCostMet: ->
    max = Number.MAX_VALUE
    for name, cost of @totalCost()
      if cost.val > 0
        max = Math.min max, cost.unit.count() / cost.val
        #console.log 'maxcostmet', @name, cost.unit.name, cost.unit.count(), cost.val, cost.unit.count()/cost.val, max
    max = Math.floor max
    util.assert max >= 0, "invalid max", max
    return max > 0

  # TODO maxCostMet, buyMax that account for costFactor
  isBuyable: ->
    return @isCostMet() and @isVisible()

  buy: ->
    if not @isCostMet()
      throw new Error "We require more resources"
    if not @isBuyable()
      throw new Error "Cannot buy that upgrade"
    @game.withSave =>
      for name, cost of @totalCost()
        util.assert cost.unit.count() >= cost.val, "tried to buy more than we can afford. upgrade.isCostMet is broken!", @name, name, cost
        cost.unit._subtractCount cost.val
      @_addCount 1
      for effect in @effect
        effect.onBuy()

  stats: (stats, schema) ->
    count = @count()
    for effect in @effect
      effect.calcStats stats, schema, count
    return stats

angular.module('swarmApp').factory 'Unit', (util) -> class Unit
  # TODO unit.unittype is needlessly long, rename to unit.type
  constructor: (@game, @unittype) ->
    @name = @unittype.name
    @_stats = _.memoize @_stats
    @_count = _.memoize @_count
  _initProducerPath: ->
    # copy all the inter-unittype references, replacing the type references with units
    @_producerPathList = _.map @unittype.producerPathList, (path) =>
      _.map path, (unittype) =>
        ret = @game.unit unittype
        util.assert ret
        return ret
    @cost = _.map @unittype.cost, (cost, name) =>
      ret = _.clone cost
      ret.unit = @game.unit cost.unittype
      return ret
    @prod = _.map @unittype.prod, (prod, name) =>
      ret = _.clone prod
      ret.unit = @game.unit prod.unittype
      return ret
    @upgrades =
      list: (upgrade for upgrade in @game.upgradelist() when @unittype == upgrade.type.unittype)
      byName: {}
    for upgrade in @upgrades.list
      @upgrades.byName[upgrade.name] = upgrade

  _producerPathData: ->
    _.map @_producerPathList, (path) =>
      tailpath = path.concat [this]
      _.map path, (parent, index) =>
        child = tailpath[index+1]
        # TODO index prod by name?
        prodlink = (prod for prod in parent.prod when prod.unit.name == child.name)
        util.assert prodlink.length == 1
        prodlink = prodlink[0]
        parent:parent
        child:child
        prod:prod

  rawCount: ->
    @game.session.unittypes[@name] ? 0
  _setCount: (val) ->
    @game.session.unittypes[@name] = val
    util.clearMemoCache @_count
  _addCount: (val) ->
    @_setCount @rawCount() + val
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
      bonus *= ancestordata.prod.val * ancestordata.parent.stat 'prod', 1
    return count * bonus / c * math.pow secs, gen

  count: -> @_count @game.now
  _count: ->
    util.clearMemoCache @_count # store only the most recent count
    secs = @game.diffSeconds()
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
    util.assert max >= 0, "invalid max", max
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
    return @isCostMet() and @isVisible() and not @unittype.unbuyable

  buyMax: ->
    @buy @maxCostMet()

  buy: (num=1) ->
    if not @isCostMet()
      throw new Error "We require more resources"
    if not @isBuyable()
      throw new Error "Cannot buy that unit"
    num = Math.min num, @maxCostMet()
    @game.withSave =>
      for cost in @cost
        cost.unit._subtractCount cost.val * num
      @_addCount num * @stat 'twin', 1

  totalProduction: ->
    ret = {}
    count = @count()
    for key, val of @eachProduction()
      ret[key] = val * count
    return ret

  eachProduction: ->
    ret = {}
    for prod in @prod
      ret[prod.unit.unittype.name] = prod.val * @stat 'prod', 1
    return ret

  stat: (key, default_=undefined) ->
    util.assert key?
    ret = @stats()[key] ? default_
    util.assert ret?, 'no such stat', @name, key
    return ret
  stats: -> @_stats()
  # No params: upgrades must clear the cache every time something changes
  _stats: ->
    stats = {}
    schema = {}
    for upgrade in @upgrades.list
      upgrade.stats stats, schema
    return stats

###*
 # @ngdoc service
 # @name swarmApp.game
 # @description
 # # game
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'Game', (unittypes, upgradetypes, util, Upgrade, Unit) -> class Game
  constructor: (@session) ->
    @_units =
      list: _.map unittypes.list, (unittype) =>
        new Unit this, unittype
      byName: {}
    for unit in @_units.list
      @_units.byName[unit.name] = unit
    @_upgrades =
      list: _.map upgradetypes.list, (upgradetype) =>
        new Upgrade this, upgradetype
      byName: {}
    for upgrade in @_upgrades.list
      @_upgrades.byName[upgrade.name] = upgrade

    for name, unit of @_units.list
      unit._initProducerPath()
    for name, upgrade of @_upgrades.list
      upgrade._init()
    @tick()

  diffMillis: ->
    @now.getTime() - @session.date.reified.getTime()

  diffSeconds: ->
    @diffMillis() / 1000

  tick: (now=new Date()) ->
    @now = now

  unit: (unitname) ->
    if _.isUndefined unitname
      return undefined
    if not _.isString unitname
      # it's a unittype?
      unitname = unitname.name
    @_units.byName[unitname]
  units: ->
    _.clone @_units.byName
  unitlist: ->
    _.clone @_units.list

  # TODO deprecated, remove in favor of unit(name).count(secs)
  count: (unitname, secs) ->
    return @unit(unitname).count secs

  counts: (secs) ->
    _.mapValues @units(), (unit, name) =>
      unit.count secs

  upgrade: (name) ->
    if not _.isString name
      name = name.name
    @_upgrades.byName[name]
  upgrades: ->
    _.clone @_upgrades.byName
  upgradelist: ->
    _.clone @_upgrades.list

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
    util.assert 0 == @diffSeconds()

  save: ->
    @withSave ->

  # A common pattern: change something (reifying first), then save the changes.
  # Use game.withSave(myFunctionThatChangesSomething) to do that.
  withSave: (fn) ->
    @reify()
    fn()
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
