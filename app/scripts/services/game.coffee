'use strict'

# achievements in achievements.coffee. TODO move the others out of this file too

angular.module('swarmApp').factory 'Effect', (util) -> class Effect
  constructor: (@game, @upgrade, data) ->
    _.extend this, data
    if data.unittype?
      @unit = util.assert @game.unit data.unittype
    if data.unittype2?
      @unit2 = util.assert @game.unit data.unittype2

  onBuy: ->
    @type.onBuy? this, @game, @upgrade

  calcStats: (stats, schema, level) ->
    @type.calcStats? this, stats, schema, level

angular.module('swarmApp').factory 'Upgrade', (util, Effect, $log) -> class Upgrade
  constructor: (@game, @type) ->
    @name = @type.name
    @unit = util.assert @game.unit @type.unittype
    @_totalCost = _.memoize @_totalCost
  _init: ->
    @costByName = {}
    @cost = _.map @type.cost, (cost) =>
      util.assert cost.unittype, 'upgrade cost without a unittype', @name, name, cost
      ret = _.clone cost
      ret.unit = util.assert @game.unit cost.unittype
      @costByName[ret.unit.name] = ret
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
    ret = @game.session.upgrades[@name] ? 0
    if _.isNaN ret
      util.error "count is NaN! resetting to zero. #{@name}"
      ret = 0
    return ret
  _setCount: (val) ->
    @game.session.upgrades[@name] = val
    util.clearMemoCache @_totalCost, @unit._stats
  _addCount: (val) ->
    @_setCount @count() + val
  _subtractCount: (val) ->
    @_addCount -val

  isVisible: ->
    if @type.maxlevel? and @count() >= @type.maxlevel
      return false
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
  _totalCost: (count=@count()) ->
    _.map @cost, (cost) ->
      total = _.clone cost
      total.val *= Math.pow total.factor, count
      return total
  sumCost: (num) ->
    _.map @totalCost(), (cost0) ->
      cost = _.clone cost0
      # special case: 1 / (1 - 1) == boom
      if cost.factor == 1
        cost.val *= num
      else
        # see maxCostMet for O(1) summation formula derivation.
        cost.val *= (1 - Math.pow cost.factor, num) / (1 - cost.factor)
      return cost
  isCostMet: ->
    max = Number.MAX_VALUE
    for cost in @totalCost()
      if cost.val > 0
        max = Math.min max, cost.unit.count() / cost.val
    max = Math.floor max
    util.assert max >= 0, "invalid max", max
    return max > 0

  maxCostMet: (percent=1) ->
    # https://en.wikipedia.org/wiki/Geometric_progression#Geometric_series
    #
    # been way too long since my math classes... given from wikipedia:
    # > cost.unit.count = cost.val (1 - cost.factor ^ maxAffordable) / (1 - cost.factor)
    # solve the equation for maxAffordable to get the formula below.
    #
    # This is O(1), but that's totally premature optimization - should really
    # have just brute forced this, we don't have that many upgrades so O(1)
    # math really doesn't matter. Yet I did it anyway. Do as I say, not as I
    # do, kids.
    max = @type.maxlevel or Number.MAX_VALUE
    for cost in @totalCost()
      util.assert cost.val > 0, 'upgrade cost <= 0', @name, this
      if cost.factor == 1 #special case: math.log(1) == 0; x / math.log(1) == boom
        m = cost.unit.count() / cost.val
      else
        m = Math.log(1 - (cost.unit.count() * percent) * (1 - cost.factor) / cost.val) / Math.log cost.factor
      max = Math.min max, m
    return Math.floor max

  # TODO maxCostMet, buyMax that account for costFactor
  isBuyable: ->
    return @isCostMet() and @isVisible()

  buy: (num=1) ->
    if not @isCostMet()
      throw new Error "We require more resources"
    if not @isBuyable()
      throw new Error "Cannot buy that upgrade"
    num = Math.min num, @maxCostMet()
    $log.debug 'buy', @name, num
    @game.withSave =>
      for cost in @sumCost num
        util.assert cost.unit.count() >= cost.val, "tried to buy more than we can afford. upgrade.maxCostMet is broken!", @name, name, cost
        util.assert cost.val > 0, "zero cost from sumCost, yet cost was met?", @name, name, cost
        cost.unit._subtractCount cost.val
      @_addCount num
      for i in [0...num]
        for effect in @effect
          effect.onBuy()
      return num

  buyMax: (percent) ->
    @buy @maxCostMet percent

  stats: (stats, schema) ->
    count = @count()
    for effect in @effect
      effect.calcStats stats, schema, count
    return stats

angular.module('swarmApp').factory 'Unit', (util, $log) -> class Unit
  # TODO unit.unittype is needlessly long, rename to unit.type
  constructor: (@game, @unittype) ->
    @name = @unittype.name
    @_stats = _.memoize @_stats
    @_count = _.memoize @_count
    @_velocity = _.memoize @_velocity
  _init: ->
    # copy all the inter-unittype references, replacing the type references with units
    @_producerPathList = _.map @unittype.producerPathList, (path) =>
      _.map path, (unittype) =>
        ret = @game.unit unittype
        util.assert ret
        return ret
    @cost = _.map @unittype.cost, (cost) =>
      ret = _.clone cost
      ret.unit = @game.unit cost.unittype
      return ret
    @prodByName = {}
    @prod = _.map @unittype.prod, (prod) =>
      ret = _.clone prod
      ret.unit = @game.unit prod.unittype
      @prodByName[ret.unit.name] = ret
      return ret
    @warnfirst = _.map @unittype.warnfirst, (warnfirst) =>
      ret = _.clone warnfirst
      ret.unit = @game.unit warnfirst.unittype
      return ret
    @upgrades =
      list: (upgrade for upgrade in @game.upgradelist() when @unittype == upgrade.type.unittype)
      byName: {}
    @showparent = @game.unit @unittype.showparent
    @requires = _.map @unittype.requires, (require) =>
      util.assert require.unittype or require.upgradetype, 'unit require without a unittype or upgradetype', @name, name, require
      util.assert not (require.unittype and require.upgradetype), 'unit require with both unittype and upgradetype', @name, name, require
      ret = _.clone require
      if require.unittype?
        ret.resource = ret.unit = util.assert @game.unit require.unittype
      if require.upgradetype?
        ret.resource = ret.upgrade = util.assert @game.upgrade require.upgradetype
      return ret
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
    ret = @game.session.unittypes[@name] ? 0
    if _.isNaN ret
      # oops. TODO alert analytics
      ret = 0
    return ret
  _setCount: (val) ->
    @game.session.unittypes[@name] = val
    util.clearMemoCache @_count, @_velocity
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
      val = ancestordata.prod.val + ancestordata.parent.stat 'base', 0
      bonus *= val * ancestordata.parent.stat 'prod', 1
    return count * bonus / c * math.pow secs, gen

  # direct parents, not grandparents/etc. Drone is parent of meat; queen is parent of drone; queen is not parent of meat.
  _parents: ->
    (pathdata[0].parent for pathdata in @_producerPathData() when pathdata[0].parent.prodByName[@name])

  count: -> @_count @game.now.getTime()
  _count: ->
    util.clearMemoCache @_count # store only the most recent count
    secs = @game.diffSeconds()
    gains = @rawCount()
    for pathdata in @_producerPathData()
      gains += @_gainsPath pathdata, secs
    return gains

  _costMetPercent: ->
    max = Number.MAX_VALUE
    for cost in @cost
      if cost.val > 0
        max = Math.min max, cost.unit.count() / cost.val
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
    if @requires.length > 0
      for require in @requires
        if require.val > require.resource.count()
          return false
      return true
    # TODO move this into the spreadsheet
    if @cost.length > 0
      # units with cost are visible at some percentage of the cost, OR when one of their immediate children exist (ex. 1 drone makes queens visible, but not nests)
      if @_costMetPercent() > 0.3
        return true
      for prod in @prod
        # 5 units: arbitrary.
        # tier-check: making parents visible is good for derivatives, but not (derivative-less) military units
        if prod.unit.unittype.tier and prod.unit.count() >= 5 #arbitrary
          return true
      return false
    else
      # costless units (ex. territory) - any producers visible?
      for path in @_producerPathList
        producer = path[0]
        if producer.isVisible()
          return true
      return false

  isBuyButtonVisible: ->
    for cost in @cost
      if not cost.unit.isVisible()
        return false
    return true

  maxCostMet: (percent=1) ->
    Math.floor @_costMetPercent() * percent

  isCostMet: ->
    @maxCostMet() > 0

  isBuyable: ->
    return @isCostMet() and @isVisible() and not @unittype.unbuyable

  buyMax: (percent) ->
    @buy @maxCostMet percent

  buy: (num=1) ->
    if not @isCostMet()
      throw new Error "We require more resources"
    if not @isBuyable()
      throw new Error "Cannot buy that unit"
    num = Math.min num, @maxCostMet()
    @game.withSave =>
      for cost in @cost
        cost.unit._subtractCount cost.val * num
      twinnum = num * @stat 'twin', 1
      @_addCount twinnum
      return {num:num, twinnum:twinnum}

  totalProduction: ->
    ret = {}
    count = @count()
    for key, val of @eachProduction()
      ret[key] = val * count
    return ret

  eachProduction: ->
    ret = {}
    for prod in @prod
      ret[prod.unit.unittype.name] = (prod.val + @stat 'base', 0) * @stat 'prod', 1
    return ret

  # speed at which other units are producing this unit.
  velocity: -> @_velocity @game.now.getTime()
  _velocity: ->
    util.clearMemoCache @_velocity # store only the most recent velocity
    sum = 0
    for parent in @_parents()
      prod = parent.totalProduction()
      util.assert prod[@name]?, "velocity: a unit's parent doesn't produce that unit?", @name, parent.name
      sum += prod[@name]
    return sum

  # TODO rework this - shouldn't have to pass a default
  hasStat: (key, default_=undefined) ->
    @stats()[key]? and @stats()[key] != default_
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

  statistics: ->
    @game.session.statistics.byUnit[@name] ? {}

###*
 # @ngdoc service
 # @name swarmApp.game
 # @description
 # # game
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'Game', (unittypes, upgradetypes, achievements, util, $log, Upgrade, Unit, Achievement) -> class Game
  constructor: (@session) ->
    @_init()
  _init: ->
    @_units =
      list: _.map unittypes.list, (unittype) =>
        new Unit this, unittype
    @_units.byName = _.indexBy @_units.list, 'name'

    @_upgrades =
      list: _.map upgradetypes.list, (upgradetype) =>
        new Upgrade this, upgradetype
    @_upgrades.byName = _.indexBy @_upgrades.list, 'name'

    @_achievements =
      list: _.map achievements.list, (achievementtype) =>
        new Achievement this, achievementtype
    @_achievements.byName = _.indexBy @_achievements.list, 'name'
    @achievementPointsPossible = achievements.pointsPossible()
    $log.debug 'possiblepoints: ', @achievementPointsPossible

    for item in [].concat @_units.list, @_upgrades.list, @_achievements.list
      item._init()
    @tick()

  diffMillis: ->
    @now.getTime() - @session.date.reified.getTime()

  diffSeconds: ->
    @diffMillis() / 1000

  tick: (now=new Date()) ->
    # TODO I hope this accounts for DST
    util.assert now, "can't tick to undefined time", now
    util.assert (not @now) or @now <= now, "tick tried to go back in time. System clock problem?", @now, now
    @now = now

  elapsedStartMillis: ->
    @now.getTime() - @session.date.started.getTime()

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

  counts: -> @countUnits()
  countUnits: ->
    _.mapValues @units(), (unit, name) =>
      unit.count()

  countUpgrades: ->
    _.mapValues @upgrades(), (upgrade, name) =>
      upgrade.count()

  upgrade: (name) ->
    if not _.isString name
      name = name.name
    @_upgrades.byName[name]
  upgrades: ->
    _.clone @_upgrades.byName
  upgradelist: ->
    _.clone @_upgrades.list

  achievement: (name) ->
    if not _.isString name
      name = name.name
    @_achievements.byName[name]
  achievements: ->
    _.clone @_achievements.byName
  achievementlist: ->
    _.clone @_achievements.list
  achievementsSorted: ->
    _.sortBy @achievementlist(), (a) ->
      a.earnedAtMillisElapsed()
  achievementPoints: ->
    util.sum _.map @achievementlist(), (a) -> a.pointsEarned()
  achievementPercent: ->
    @achievementPoints() / @achievementPointsPossible

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

  importSave: (encoded) ->
    @session.importSave encoded
    # Force-clear various caches.
    @_init()
    # No errors - successful import. Save now, so refreshing the page uses the import.
    @session.save()

  # A common pattern: change something (reifying first), then save the changes.
  # Use game.withSave(myFunctionThatChangesSomething) to do that.
  withSave: (fn) ->
    @reify()
    ret = fn()
    @session.save()
    return ret

  reset: ->
    @session.reset()
    @_init()
    for unit in @unitlist()
      unit._setCount unit.unittype.init
    @save()

angular.module('swarmApp').factory 'game', (Game, session, $log) ->
  game = new Game session
  try
    session.load()
    $log.debug 'Game data loaded successfully.', this
  catch
    $log.debug 'Failed to load saved data! Resetting.'
    game.reset()
  return game
