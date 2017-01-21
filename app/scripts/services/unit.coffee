'use strict'

angular.module('swarmApp').factory 'ProducerPath', ($log, UNIT_LIMIT) -> class ProducerPath
  constructor: (@unit, @path) ->
    pathname = _.map(@path, (p) => p.parent.name).join '>'
    # unit.name's in the name twice, just so there's no confusion about where the path ends
    @name = "#{@unit.name}:#{pathname}>#{@unit.name}"
  first: -> @path[0]
  isZero: -> @first().parent.count().isZero()
  degree: -> @path.length
  degreeOrZero: -> if @isZero() then 0 else @degree()
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
        ret = Decimal.min ret, UNIT_LIMIT
      return ret
  coefficient: (count=@first().parent.rawCount()) ->
    # floor(): no fractional units. #184
    count.floor().times @prodEach()
  coefficientNow: ->
    @coefficient @first().parent.count()
  count: (secs) ->
    degree = @degree()
    coeff = @coefficient()
    # c * (t^d)/d!
    return coeff.times(Decimal.pow(secs, degree)).dividedBy(math.factorial degree)

angular.module('swarmApp').factory 'ProducerPaths', ($log, ProducerPath) -> class ProducerPaths
  constructor: (@unit, @raw) ->
    @list = _.map @raw, (path) =>
      tailpath = path.concat [@unit]
      return new ProducerPath @unit, _.map path, (parent, index) =>
        child = tailpath[index+1]
        prodlink = parent.prodByName[child.name]
        parent:parent
        child:child
        prod:prodlink
    @byDegree = _.groupBy @list, (path) ->
      path.degree()

  getDegreeCoefficient: (degree, now=false) ->
    ret = new Decimal 0
    for path in @byDegree[degree] ? []
      ret = ret.plus if now then path.coefficientNow() else path.coefficient()
    return ret

  # Highest polynomial degree of this unit's production chain where the ancestor has nonzero count.
  # Or, how many parents it has. Examples of degree:
  #
  # [drone] is degree 0 (constant, rawcount() with no time factor)
  # [drone > meat] is degree 1
  # [queen > drone > meat] is degree 2
  # [nest > queen > drone > meat] is degree 3
  # [nest > queen > drone] is degree 2
  getMaxDegree: ->
    return @getCoefficients().length - 1

  getCoefficients: ->
    return @unit.game.cache.producerPathCoefficients[@unit.name] ?= @_getCoefficients()

  _getCoefficients: (now=false) ->
    # array indexes are polynomial degrees, values are coefficients
    # [1, 3, 5, 7] = 7t^3 + 5t^2 + 3t + 1
    ret = [if now then @unit.count() else @unit.rawCount()]
    for pathdata in @list
      degree = pathdata.degree()
      coefficient = if now then pathdata.coefficientNow() else pathdata.coefficient()
      if not coefficient.isZero()
        ret[degree] = (ret[degree] ? new Decimal 0).plus coefficient
    for coeff, degree in ret
      if not coeff?
        ret[degree] = new Decimal 0
    return ret

  getCoefficientsNow: ->
    return @_getCoefficients true
  
  count: (secs) ->
    # Horner's method should be faster here:
    # https://en.wikipedia.org/wiki/Horner's_method
    # http://jsbin.com/doqudoxopo/edit?html,output
    # ...but I tried it and it wasn't.
    ret = new Decimal 0
    for coeff, degree in @getCoefficients()
      # c * (t^d)/d!
      ret = ret.plus coeff.times(Decimal.pow(secs, degree)).dividedBy(math.factorial degree)
    return ret

angular.module('swarmApp').factory 'Unit', (util, $log, Effect, ProducerPaths, UNIT_LIMIT) -> class Unit
  # TODO unit.unittype is needlessly long, rename to unit.type
  constructor: (@game, @unittype) ->
    @name = @unittype.name
    @suffix = ''
    @affectedBy = []
    @type = @unittype # start transitioning now
  _init: ->
    @prod = _.map @unittype.prod, (prod) =>
      ret = _.clone prod
      ret.unit = @game.unit prod.unittype
      ret.val = new Decimal ret.val
      return ret
    @prodByName = _.keyBy @prod, (prod) -> prod.unit.name
    @cost = _.map @unittype.cost, (cost) =>
      ret = _.clone cost
      ret.unit = @game.unit cost.unittype
      ret.val = new Decimal ret.val
      return ret
    @costByName = _.keyBy @cost, (cost) -> cost.unit.name
    @warnfirst = _.map @unittype.warnfirst, (warnfirst) =>
      ret = _.clone warnfirst
      ret.unit = @game.unit warnfirst.unittype
      return ret
    @showparent = @game.unit @unittype.showparent
    @upgrades =
      list: (upgrade for upgrade in @game.upgradelist() when @unittype == upgrade.type.unittype or @showparent?.unittype == upgrade.type.unittype)
    @upgrades.byName = _.keyBy @upgrades.list, 'name'
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
  # hacky, but we need two stages of init() for our object graph: all unit->unittype, all prod->unit, all producerpath->prod
  _init2: ->
    # copy all the inter-unittype references, replacing the type references with units
    @_producerPath = new ProducerPaths this, _.map @unittype.producerPathList, (path) =>
      _.map path, (unittype) =>
        ret = @game.unit unittype
        util.assert ret
        return ret

  isCountInitialized: ->
    return @game.session.state.unittypes[@name]?
  rawCount: ->
    return @game.cache.unitRawCount[@name] ?= do =>
      # caching's helpful to avoid re-parsing session strings
      ret = @game.session.state.unittypes[@name] ? 0
      if _.isNaN ret
        util.error 'NaN count. oops.', @name, ret
        ret = 0
      # toPrecision avoids Decimal errors when converting old saves
      if _.isNumber ret
        ret = ret.toPrecision 15
      return new Decimal ret
  _setCount: (val) ->
    @game.session.state.unittypes[@name] = new Decimal val
    @game.cache.onUpdate()
  _addCount: (val) ->
    @_setCount @rawCount().plus(val)
  _subtractCount: (val) ->
    @_addCount new Decimal(val).times(-1)

  # direct parents, not grandparents/etc. Drone is parent of meat; queen is parent of drone; queen is not parent of meat.
  _parents: ->
    (pathdata.first().parent for pathdata in @_producerPath.list when pathdata.first().parent.prodByName[@name])

  _getCap: ->
    return @game.cache.unitCap[@name] ?= do =>
      if @hasStat 'capBase'
        ret = @stat 'capBase'
        ret = ret.times @stat 'capMult', 1
        return ret
  capValue: (val) ->
    cap = @_getCap()
    if not cap?
      # if both are undefined, prefer undefined to NaN, mostly for legacy
      if not val?
        return val
      return Decimal.min val, UNIT_LIMIT
    if not val?
      # no value supplied - return just the cap
      return cap
    return Decimal.min val, cap

  capPercent: ->
    if (cap = @capValue())?
      return @count().dividedBy(cap)
  capDurationSeconds: ->
    if (cap = @capValue())?
      return @estimateSecsUntilEarned(cap).toNumber?() ? 0
  capDurationMoment: ->
    if (secs = @capDurationSeconds())?
      return moment.duration secs, 'seconds'

  @ESTIMATE_BISECTION: true
  isEstimateExact: ->
    # Bisection estimates are precise enough to not say "or less" next to, too.
    return @_producerPath.getMaxDegree() <= 2 or @constructor.ESTIMATE_BISECTION
  isEstimateCacheable: ->
    # Bisection estimates are precise enough to cache. 50 iterations is quick and covers estimates up to like 10 years.
    return @_producerPath.getMaxDegree() <= 2 or @constructor.ESTIMATE_BISECTION
  estimateSecsUntilEarned: (num) ->
    count = @count()
    num = new Decimal num
    remaining = num.minus count
    if remaining.lessThanOrEqualTo 0
      return 0
    degree = @_producerPath.getMaxDegree()
    #$log.debug 'estimating degree', degree
    coeffs = @_producerPath.getCoefficientsNow()
    ret = new Decimal Infinity
    if degree > 0
      # TODO this is exact, don't clear the cache periodically
      if not coeffs[1].isZero()
        linear = ret = Decimal.min ret, remaining.dividedBy coeffs[1]
        #$log.debug 'linear estimate', ret+''
      if degree > 1
        # quadratic formula: (-b +/- (b^2 - 4ac)^0.5) / 2a
        # TODO this is exact, don't clear the cache periodically
        [_, b, a] = coeffs
        if not a.isZero()
          c = remaining.negated()
          a = a.dividedBy 2 # for the "/2!" in "c * t^2/2!"
          # a > 0, b >= 0, c < 0: `root` is always positive/non-imaginary, and + is the correct choice for +/- because - will always be a negative root which doesn't make sense for this problem
          #$log.debug 'quadratic: ', a+'', b+'', c+''
          disc = b.times(b).minus(a.times(c).times(4)).sqrt()
          quadratic = ret = Decimal.min ret, b.negated().plus(disc).dividedBy(a.times 2)
          #$log.debug 'quadratic estimate', ret+''
          # TODO there's an exact cubic formula, isn't there? implement it.
        if degree > 2
          if @constructor.ESTIMATE_BISECTION
            # Bisection method - slower/more complex, but more precise
            # if we couldn't pick a starting point, pretend a second's passed and try again, possibly quitting if we finished in a second or less. This basically only happens in unit tests.
            maxSec = linear ? remaining.dividedBy @_countInSecsFromNow(new Decimal(1)).minus(count)
            if not maxSec.greaterThan(0)
              ret = new Decimal(1)
            else
              ret = @estimateSecsUntilEarnedBisection num, maxSec
          else
            # Estimate from minimum degree - faster/simpler, but less precise
            # http://www.kongregate.com/forums/4545-swarm-simulator/topics/473244-time-remaining-suggestion?page=1#posts-8985615
            for coeff, deg in coeffs[3...]
              # remaining (r) = c * (t^d)/d!
              # solve for t: r * d! / c = t^d
              # solve for t: (r * d! / c) ^ (1/d) = t
              if not coeff.isZero()
                #loop starts iterating from 0, not 3. no need to recalculate first few degrees, we did more precise math for them earlier.
                deg += 3
                ret = Decimal.min ret, remaining.dividedBy(coeff).times(math.factorial deg).pow(new Decimal(1).dividedBy deg)
                #$log.debug 'single-degree estimate', deg, ret+''
    #$log.debug 'done estimating', ret.toNumber()
    return ret

  estimateSecsUntilEarnedBisection: (num, origMaxSec) ->
    $log.debug 'bisecting'
    # https://en.wikipedia.org/wiki/Bisection_method#Algorithm
    f = (sec) =>
      num.minus @_countInSecsFromNow sec
    isInThresh = (min, max) ->
      # Different thresholds for different search spaces
      # (We don't care about seconds if the result's in days)
      thresh = new Decimal 0.2
      #if min < 60 * 60
      #  thresh = 1
      #else if min < 60 * 60 * 24
      #  thresh = 60
      #else
      #  thresh = 60 * 60
      return max.minus(min).dividedBy(2).lessThan(thresh)

    minSec = new Decimal 0
    # No estimates longer than two years, because seriously, why?
    # Because endgame swarmwarps, that's why.
    #maxSec = Decimal.min origMaxSec, 86400 * 365 * 2
    maxSec = origMaxSec
    minVal = f minSec
    maxVal = f maxSec
    iteration = 0
    starttime = new Date().getTime()
    done = false
    # 40 iterations gives 0.1-second precision for any estimate that starts below 3000 years. Should be plenty.
    # ...swarmwarp demands some damn big iterations. *50* should be plenty.
    while iteration < 50 and not done
      iteration += 1
      midSec = maxSec.plus(minSec).dividedBy(2)
      midVal = f midSec
      #$log.debug "bisection estimate: iteration #{iteration}, midsec #{midSec}, midVal #{midVal}"
      if midVal.isZero() or isInThresh minSec, maxSec
        done = true
      else if (midVal.isNegative()) == (minVal.isNegative())
        minSec = midSec
        minVal = f minSec
      else
        maxSec = midSec
        maxVal = f maxSec
    # too many iterations
    timediff = new Date().getTime() - starttime
    if not done
      $log.debug "bisection estimate for #{@name} took more than #{iteration} iterations; quitting. precision: #{maxSec.minus(minSec).dividedBy(2)} (down from #{origMaxSec}). time: #{timediff}"
    else
      $log.debug "bisection estimate for #{@name} finished in #{iteration} iterations. original range: #{origMaxSec}, estimate is #{midSec} - plus game.difftime of #{@game.diffSeconds()}, that's #{midSec.plus(@game.diffSeconds())} - this shouldn't change much over multiple iterations. time: #{timediff}"
    return midSec

  count: ->
    return @game.cache.unitCount[@name] ?= @_countInSecsFromNow()

  _countInSecsFromNow: (secs=new Decimal 0) ->
    return @_countInSecsFromReified secs.plus(@game.diffSeconds())
  _countInSecsFromReified: (secs=0) ->
    return @capValue @_producerPath.count secs

  # All units that cost this unit.
  spentResources: ->
    (u for u in [].concat(@game.unitlist(), @game.upgradelist()) when u.costByName[@name]?)
  spent: (ignores={}) ->
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
    #util.assert max.greaterThanOrEqualTo(0), "invalid unit cost max", @name
    return max

  _costMetPercentOfVelocity: ->
    max = new Decimal Infinity
    for cost in @eachCost()
      if cost.val.greaterThan(0)
        max = Decimal.min max, cost.unit.velocity().dividedBy cost.val
    #util.assert max.greaterThanOrEqualTo(0), "invalid unit cost max", @name
    return max
  
  isVisible: ->
    if @unittype.disabled
      return false
    if @game.cache.unitVisible[@name]
      return true
    return @game.cache.unitVisible[@name] = @_isVisible()

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
      
  maxCostMetOfVelocity: () ->
    return @game.cache.unitMaxCostMetOfVelocity["#{@name}"] ?= do =>
      @_costMetPercentOfVelocity()
  
  maxCostMetOfVelocityReciprocal: () ->
    (new Decimal 1).dividedBy(@maxCostMetOfVelocity())

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

  isNewlyUpgradable: ->
    upgrades = @showparent?.upgrades?.list ? @upgrades.list
    _.some upgrades, (upgrade) ->
      upgrade.isVisible() and upgrade.isNewlyUpgradable()

  totalProduction: ->
    return @game.cache.totalProduction[@name] ?= do =>
      ret = {}
      count = @count().floor()
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
    return @game.cache.velocity[@name] ?= Decimal.min UNIT_LIMIT, @_producerPath.getDegreeCoefficient(1, true)

  isVelocityConstant: ->
    return @_producerPath.getMaxCoefficient() <= 1

  # TODO rework this - shouldn't have to pass a default
  hasStat: (key, default_=undefined) ->
    @stats()[key]? and @stats()[key] != default_
  stat: (key, default_=undefined) ->
    util.assert key?
    if default_?
      default_ = new Decimal default_
    ret = @stats()[key] ? default_
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
    @game.session.state.statistics?.byUnit?[@name] ? {}

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
        _.map path, 'name'

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
        util.assert cost.val > 0 or (unittype.unbuyable and unittype.disabled), "unittype cost.val must be positive", cost
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
