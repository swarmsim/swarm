'use strict'

angular.module('swarmApp').factory 'ProducerPath', ($log) -> class ProducerPath
  constructor: (@unit, @path) ->
    pathname = _.map(@path, (p) => p.parent.name).join '>'
    # unit.name's in the name twice, just so there's no confusion about where the path ends
    @name = "#{@unit.name}:#{pathname}>#{@unit.name}"
  first: -> @path[0]
  prodEach: ->
    return @unit.game.cache.producerPathProdEach[@name] ?= do =>
      # Bonus for ancestor to produced-child == product of all bonuses along the path
      # (intuitively, if velocity and velocity-changes are doubled, acceleration is doubled too)
      # Quantity of buildings along the path do not matter, they're calculated separately.
      ret = new Decimal 1
      for ancestordata in @path
        val = new Decimal(ancestordata.prod.val).plus ancestordata.parent.stat 'base', 0
        ret = ret.times val
        ret = ret.times ancestordata.parent.stat 'prod', 1
        # Cap ret, just like count(). This prevents Infinity * 0 = NaN problems, too.
        ret = Decimal.min ret, 1e300
      return ret

angular.module('swarmApp').factory 'Unit', (util, $log, Effect, ProducerPath) -> class Unit
  # TODO unit.unittype is needlessly long, rename to unit.type
  constructor: (@game, @unittype) ->
    @name = @unittype.name
    @suffix = ''
    @affectedBy = []
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
      ret.val = new Decimal ret.val
      return ret
    @costByName = _.indexBy @cost, (cost) -> cost.unit.name
    @prod = _.map @unittype.prod, (prod) =>
      ret = _.clone prod
      ret.unit = @game.unit prod.unittype
      ret.val = new Decimal ret.val
      return ret
    @prodByName = _.indexBy @prod, (prod) -> prod.unit.name
    @warnfirst = _.map @unittype.warnfirst, (warnfirst) =>
      ret = _.clone warnfirst
      ret.unit = @game.unit warnfirst.unittype
      return ret
    @showparent = @game.unit @unittype.showparent
    @upgrades =
      list: (upgrade for upgrade in @game.upgradelist() when @unittype == upgrade.type.unittype or @showparent?.unittype == upgrade.type.unittype)
    @upgrades.byName = _.indexBy @upgrades.list, 'name'
    @upgrades.byClass = _.groupBy @upgrades.list, (u) -> u.type.class

    @requires = _.map @unittype.requires, (require) =>
      util.assert require.unittype or require.upgradetype, 'unit require without a unittype or upgradetype', @name, name, require
      util.assert not (require.unittype and require.upgradetype), 'unit require with both unittype and upgradetype', @name, name, require
      ret = _.clone require
      ret.val = new Decimal ret.val
      if require.unittype?
        ret.resource = ret.unit = util.assert @game.unit require.unittype
      if require.upgradetype?
        ret.resource = ret.upgrade = util.assert @game.upgrade require.upgradetype
      return ret
    @cap = _.map @unittype.cap, (capspec) =>
      ret = _.clone capspec
      ret.unit = @game.unit ret.unittype
      ret.val = new Decimal ret.val
      return ret
    @effect = _.map @unittype.effect, (effect) =>
      ret = new Effect @game, this, effect
      ret.unit.affectedBy.push ret
      return ret

    @tab = @game.tabs.byName[@unittype.tab]
    if @tab
      @next = @tab.next this
      @prev = @tab.prev this

  _producerPathData: ->
    return @__producerPathData ?= _.map @_producerPathList, (path) =>
      tailpath = path.concat [this]
      return new ProducerPath this, _.map path, (parent, index) =>
        child = tailpath[index+1]
        # TODO index prod by name?
        prodlink = (prod for prod in parent.prod when prod.unit.name == child.name)
        util.assert prodlink.length == 1
        prodlink = prodlink[0]
        parent:parent
        child:child
        prod:prodlink

  rawCount: ->
    return @game.cache.unitRawCount[@name] ?= do =>
      # caching's helpful to avoid re-parsing session strings
      ret = @game.session.unittypes[@name] ? 0
      if _.isNaN ret
        util.error 'NaN count. oops.', @name, ret
        ret = 0
      return new Decimal ret
  _setCount: (val) ->
    @game.session.unittypes[@name] = new Decimal val
    @game.cache.onUpdate()
  _addCount: (val) ->
    @_setCount @rawCount().plus(val)
  _subtractCount: (val) ->
    @_addCount new Decimal(val).times(-1)

  _gainsPath: (pathdata, secs) ->
    producerdata = pathdata.first()
    gen = pathdata.path.length
    c = math.factorial gen
    count = producerdata.parent.rawCount()
    prodEach = pathdata.prodEach()
    return prodEach.times(count).dividedBy(c).times(Decimal.pow(secs, gen))

  # direct parents, not grandparents/etc. Drone is parent of meat; queen is parent of drone; queen is not parent of meat.
  _parents: ->
    (pathdata.first().parent for pathdata in @_producerPathData() when pathdata.first().parent.prodByName[@name])

  _getCap: ->
    if @hasStat 'capBase'
      ret = @stat 'capBase'
      ret = ret.times @stat 'capMult', 1
      return ret
    #cap = 0
    #for capspec in @cap
    #  capval = capspec.val
    #  if capspec.unit?
    #    capval *= capspec.unit.count()
    #  cap += capval
    #util.assert cap >= 0, 'negative cap', @name, cap
    #return cap
  capValue: (val) ->
    cap = @_getCap()
    if not cap?
      # if both are undefined, prefer undefined to NaN, mostly for legacy
      if not val?
        return val
      return Decimal.min val, 1e+300
    if not val?
      # no value supplied - return just the cap
      return cap
    return Decimal.min val, cap

  capPercent: ->
    if (cap = @capValue())?
      return @count().dividedBy(cap)
  capDurationSeconds: ->
    if (cap = @capValue())?
      return @estimateSecs cap
  capDurationMoment: ->
    if (secs = @capDurationSeconds())?
      return moment.duration secs, 'seconds'

  estimateSecs: (num) ->
    # result is *not* a bigdecimal!
    remaining = new Decimal(num).minus @count()
    if remaining.lessThanOrEqualTo 0
      return 0
    velocity = @velocity()
    if velocity.lessThanOrEqualTo 0
      return Infinity
    secs = remaining.dividedBy velocity
    # verify it's linear
    #estimate = @_countInSecsFromNow secs
    #if util.isFloatEqual num, estimate, 0.1
    #  return secs
    #throw new Error 'nonlinear estimation not yet implemented'
    # fuck it. TODO nonlinear estimation
    return secs.toNumber()

  count: ->
    return @game.cache.unitCount[@name] ?= @_countInSecsFromNow 0

  _countInSecsFromNow: (secs=0) ->
    return @_countInSecsFromReified @game.diffSeconds() + secs
  _countInSecsFromReified: (secs=0) ->
    count = @rawCount()
    for pathdata in @_producerPathData()
      count = count.plus @_gainsPath pathdata, secs
    return @capValue count

  # All units that cost this unit.
  spentResources: ->
    (u for u in [].concat(@game.unitlist(), @game.upgradelist()) when u.costByName[@name]?)
  spent: (ignores={})->
    ret = new Decimal 0
    for u in @game.unitlist()
      costeach = u.costByName[@name]?.val ? 0
      ret = ret.plus u.count().times costeach
    for u in @game.upgradelist()
      if u.costByName[@name] and not ignores[u.name]?
        # cost for $count upgrades starting from level 1
        costs = u.sumCost u.count(), 0
        cost = _.find costs, (c) => c.unit.name == @name
        ret = ret.plus cost?.val ? 0
    return ret

  _costMetPercent: ->
    max = new Decimal Infinity
    for cost in @eachCost()
      if cost.val.greaterThan(0)
        max = Decimal.min max, cost.unit.count().dividedBy cost.val
    util.assert max.greaterThanOrEqualTo(0), "invalid unit cost max", @name
    return max

  isVisible: ->
    if @unittype.disabled
      return false
    if @_visible
      return true
    return @_visible = @_isVisible()

  _isVisible: ->
    if @count().greaterThan 0
      return true
    util.assert @requires.length > 0, "unit without visibility requirements", @name
    for require in @requires
      if require.val.greaterThan require.resource.count()
        if require.op != 'OR' # most requirements are ANDed, any one failure fails them all
          return false
        # req-not-met for OR requirements: no-op
      else if require.op == 'OR' # single necessary requirement is met
        return true
    return true

  isBuyButtonVisible: ->
    eachCost = @eachCost()
    if @unittype.unbuyable or eachCost.length == 0
      return false
    for cost in eachCost
      if not cost.unit.isVisible()
        return false
    return true

  maxCostMet: (percent=1) ->
    return @game.cache.unitMaxCostMet["#{@name}:#{percent}"] ?= do =>
      @_costMetPercent().times(percent).floor()

  isCostMet: ->
    @maxCostMet().greaterThan 0

  isBuyable: (ignoreCost=false) ->
    return (@isCostMet() or ignoreCost) and @isVisible() and not @unittype.unbuyable

  buyMax: (percent) ->
    @buy @maxCostMet percent

  twinMult: ->
    ret = new Decimal 1
    ret = ret.plus @stat 'twinbase', 0
    ret = ret.times @stat 'twin', 1
    return ret
  buy: (num=1) ->
    if not @isCostMet()
      throw new Error "We require more resources"
    if not @isBuyable()
      throw new Error "Cannot buy that unit"
    num = Decimal.min num, @maxCostMet()
    @game.withSave =>
      for cost in @eachCost()
        cost.unit._subtractCount cost.val.times num
      twinnum = num.times @twinMult()
      @_addCount twinnum
      return {num:num, twinnum:twinnum}

  viewNewUpgrades: ->
    upgrades = @showparent?.upgrades?.list ? @upgrades.list
    for upgrade in upgrades
      upgrade.viewNewUpgrades()
  isNewlyUpgradable: ->
    upgrades = @showparent?.upgrades?.list ? @upgrades.list
    _.some upgrades, (upgrade) ->
      upgrade.isVisible() and upgrade.isNewlyUpgradable()

  totalProduction: ->
    return @game.cache.totalProduction[@name] ?= do =>
      ret = {}
      count = @count()
      for key, val of @eachProduction()
        ret[key] = val.times count
      return ret

  eachProduction: ->
    return @game.cache.eachProduction[@name] ?= do =>
      ret = {}
      for prod in @prod
        ret[prod.unit.unittype.name] = (prod.val.plus @stat 'base', 0).times @stat 'prod', 1
      return ret

  eachCost: ->
    return @game.cache.eachCost[@name] ?= _.map @cost, (cost) =>
      cost = _.clone cost
      cost.val = cost.val.times(@stat 'cost', 1).times(@stat "cost.#{cost.unit.unittype.name}", 1)
      return cost

  # speed at which other units are producing this unit.
  velocity: ->
    return @game.cache.velocity[@name] ?= do =>
      sum = new Decimal 0
      for parent in @_parents()
        prod = parent.totalProduction()
        util.assert prod[@name]?, "velocity: a unit's parent doesn't produce that unit?", @name, parent.name
        sum = sum.plus prod[@name]
      # global anti-infinity cap just like count()
      return Decimal.min 1e300, sum

  isVelocityConstant: ->
    for parent in @_parents()
      if parent.velocity() > 0
        return false
    return true

  # TODO rework this - shouldn't have to pass a default
  hasStat: (key, default_=undefined) ->
    @stats()[key]? and @stats()[key] != default_
  stat: (key, default_=undefined) ->
    util.assert key?
    ret = @stats()[key] ? new Decimal default_
    util.assert ret?, 'no such stat', @name, key
    return new Decimal ret
  stats: ->
    return @game.cache.stats[@name] ?= do =>
      stats = {}
      schema = {}
      for upgrade in @upgrades.list
        upgrade.calcStats stats, schema
      for uniteffect in @affectedBy
        uniteffect.calcStats stats, schema, uniteffect.parent.count()
      return stats

  statistics: ->
    @game.session.statistics.byUnit[@name] ? {}

  # TODO centralize url handling
  url: ->
    @tab.url this


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
    @producerPath = {}
    @producerPathList = []

  producerNames: ->
    _.mapValues @producerPath, (paths) ->
      _.map paths, (path) ->
        _.pluck path, 'name'

angular.module('swarmApp').factory 'UnitTypes', (spreadsheetUtil, UnitType, util, $log) -> class UnitTypes
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
    unittype.producerPathList.push path
    unittype.producerPath[producer.name] ?= []
    unittype.producerPath[producer.name].push path
    for nextgen in producer.producedBy
      @_buildProducerPath unittype, nextgen, path

  @parseSpreadsheet: (effecttypes, data) ->
    rows = spreadsheetUtil.parseRows {name:['cost','prod','warnfirst','requires','cap','effect']}, data.data.unittypes.elements
    ret = new UnitTypes (new UnitType(row) for row in rows)
    for unittype in ret.list
      unittype.producedBy = []
      unittype.affectedBy = []
    for unittype in ret.list
      #unittype.tick = if unittype.tick then moment.duration unittype.tick else null
      #unittype.cooldown = if unittype.cooldown then moment.duration unittype.cooldown else null
      # replace names with refs
      if unittype.showparent
        spreadsheetUtil.resolveList [unittype], 'showparent', ret.byName
      spreadsheetUtil.resolveList unittype.cost, 'unittype', ret.byName
      spreadsheetUtil.resolveList unittype.prod, 'unittype', ret.byName
      spreadsheetUtil.resolveList unittype.warnfirst, 'unittype', ret.byName
      spreadsheetUtil.resolveList unittype.requires, 'unittype', ret.byName, {required:false}
      spreadsheetUtil.resolveList unittype.cap, 'unittype', ret.byName, {required:false}
      spreadsheetUtil.resolveList unittype.effect, 'unittype', ret.byName
      spreadsheetUtil.resolveList unittype.effect, 'type', effecttypes.byName
      # oops - we haven't parsed upgradetypes yet! done in upgradetype.coffee.
      #spreadsheetUtil.resolveList unittype.require, 'upgradetype', ret.byName
      unittype.slug = unittype.label
      for prod in unittype.prod
        prod.unittype.producedBy.push unittype
        util.assert prod.val > 0, "unittype prod.val must be positive", prod
      for cost in unittype.cost
        util.assert cost.val > 0, "unittype cost.val must be positive", cost
    for unittype in ret.list
      for producer in unittype.producedBy
        @_buildProducerPath unittype, producer, []
    $log.debug 'built unittypes', ret
    return ret

###*
 # @ngdoc service
 # @name swarmApp.units
 # @description
 # # units
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'unittypes', (UnitTypes, effecttypes, spreadsheet) ->
  return UnitTypes.parseSpreadsheet effecttypes, spreadsheet
