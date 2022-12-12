'use strict'

angular.module('swarmApp').factory 'Upgrade', (util, Effect, $log) ->
  ONE = new Decimal(1)

  return class Upgrade
    constructor: (@game, @type) ->
      @name = @type.name
      @unit = util.assert @game.unit @type.unittype
    _init: ->
      @costByName = {}
      @cost = _.map @type.cost, (cost) =>
        util.assert cost.unittype, 'upgrade cost without a unittype', @name, name, cost
        ret = _.clone cost
        ret.unit = util.assert @game.unit cost.unittype
        ret.val = new Decimal ret.val
        ret.factor = new Decimal ret.factor
        @costByName[ret.unit.name] = ret
        return ret
      @requires = _.map @type.requires, (require) =>
        util.assert require.unittype, 'upgrade require without a unittype', @name, name, require
        ret = _.clone require
        ret.unit = util.assert @game.unit require.unittype
        ret.val = new Decimal ret.val
        return ret
      @effect = _.map @type.effect, (effect) =>
        return new Effect @game, this, effect
      @effectByType = _.groupBy @effect, 'type.name'
    # TODO refactor counting to share with unit
    count: ->
      ret = @game.session.state.upgrades[@name] ? 0
      if _.isNaN ret
        util.error "count is NaN! resetting to zero. #{@name}"
        ret = 0
      # we shouldn't ever exceed maxlevel, but just in case...
      if @type.maxlevel
        ret = Decimal.min @type.maxlevel, ret
      return new Decimal ret
    _setCount: (val) ->
      @game.session.state.upgrades[@name] = new Decimal val
      @game.cache.onUpdate()
    _addCount: (val) ->
      @_setCount @count().plus val
    _subtractCount: (val) ->
      @_addCount new Decimal(val).negated()
  
    isVisible: ->
      # disabled: hack for larvae/showparent. We really need to just remove showparent already...
      if not @unit.isVisible() and not @unit.unittype.disabled
        return false
      if @type.maxlevel? and @count().greaterThanOrEqualTo @type.maxlevel
        return false
      if @type.disabled
        return false
      if @game.cache.upgradeVisible[@name]
        return true
      return @game.cache.upgradeVisible[@name] = @_isVisible()
    _isVisible: ->
      if @count().greaterThan 0
        return true
      for require in @requires
        if require.val.greaterThan require.unit.count()
          return false
      return true
    totalCost: ->
      return @game.cache.upgradeTotalCost[@name] ?= @_totalCost()
    _totalCost: (count=@count().plus(@unit.stat 'upgradecost', 0)) ->
      _.map @cost, (cost) =>
        total = _.clone cost
        total.val = total.val.times(Decimal.pow total.factor, count).times(@unit.stat "upgradecostmult", 1).times(@unit.stat "upgradecostmult.#{@name}", 1)
        return total
    sumCost: (num, startCount) ->
      _.map @_totalCost(startCount), (cost0) ->
        cost = _.clone cost0
        # special case: 1 / (1 - 1) == boom
        if cost.factor.equals 1
          cost.val = cost.val.times num
        else
          # see maxCostMet for O(1) summation formula derivation.
          # cost.val *= (1 - Math.pow cost.factor, num) / (1 - cost.factor)
          cost.val = cost.val.times ONE.minus(Decimal.pow cost.factor, num).dividedBy(ONE.minus cost.factor)
        return cost
    isCostMet: ->
      return @maxCostMet().greaterThan 0
  
    maxCostMet: (percent=1) ->
      return @game.cache.upgradeMaxCostMet["#{@name}:#{percent}"] ?= do =>
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
        max = new Decimal Infinity
        if @type.maxlevel
          max = new Decimal(@type.maxlevel).minus(@count())
        for cost in @totalCost()
          util.assert cost.val.greaterThan(0), 'upgrade cost <= 0', @name, this
          if cost.factor.equals(1) #special case: math.log(1) == 0; x / math.log(1) == boom
            m = cost.unit.count().dividedBy(cost.val)
          else
            #m = Math.log(1 - (cost.unit.count() * percent) * (1 - cost.factor) / cost.val) / Math.log cost.factor
            m = ONE.minus(cost.unit.count().times(percent).times(ONE.minus cost.factor).dividedBy(cost.val)).log().dividedBy(cost.factor.log())
          max = Decimal.min max, m
          #$log.debug 'iscostmet', @name, cost.unit.name, m, max, cost.unit.count(), cost.val
        # sumCost is sometimes more precise than maxCostMet, leading to buy() breaking - #290.
        # Compare our result here with sumCost, and adjust if precision's a problem.
        max = max.floor()
        if max.greaterThanOrEqualTo 0 # just in case
          for cost in @sumCost max
            # maxCostMet is supposed to guarantee we have more units than the cost of this many upgrades!
            # if that's not true, it must be a precision error.
            if cost.unit.count().lessThan cost.val
              $log.debug 'maxCostMet corrected its own precision'
              return max.minus 1
        return max
  
    isMaxAffordable: ->
      return @type.maxlevel? and @maxCostMet().greaterThanOrEqualTo(@type.maxlevel)
  
    costMetPercent: ->
      costOfMet = _.keyBy @sumCost(@maxCostMet()), (c) -> c.unit.name
      max = new Decimal Infinity
      if @isMaxAffordable()
        return ONE
      for cost in @sumCost @maxCostMet().plus(1)
        count = cost.unit.count().minus costOfMet[cost.unit.name].val
        val = cost.val.minus costOfMet[cost.unit.name].val
        max = Decimal.min max, (count.dividedBy val)
      return Decimal.min 1, Decimal.max 0, max
  
    estimateSecsUntilBuyable: (noRecurse) ->
      if @isMaxAffordable()
        return {val:new Decimal Infinity}
      # tricky caching - take the estimated when it was cached, then subtract time that's passed since then.
      cached = @game.cache.upgradeEstimateSecsUntilBuyableCacheSafe[@name]
      if not cached?
        cached = @game.cache.upgradeEstimateSecsUntilBuyablePeriodic[@name] ?= @_estimateSecsUntilBuyable()
        # Some estimates can be cached more permanently (until update)
        if cached.cacheSafe
          @game.cache.upgradeEstimateSecsUntilBuyableCacheSafe[@name] = cached
      ret = _.extend {val:cached.rawVal.plus (cached.now - @game.now.getTime())/1000}, cached
      # we can now afford the cached upgrade! clear cache, pick another one.
      if ret.val.lessThanOrEqualTo(0) and not noRecurse
        delete @game.cache.upgradeEstimateSecsUntilBuyableCacheSafe[@name]
        delete @game.cache.upgradeEstimateSecsUntilBuyablePeriodic[@name]
        ret = @estimateSecsUntilBuyable true
      return ret
      
    _estimateSecsUntilBuyable: ->
      costOfMet = _.keyBy @sumCost(@maxCostMet()), (c) -> c.unit.name
      cacheSafe = true
      max = {rawVal:new Decimal(0), unit:null}
      if @type.maxlevel? and @maxCostMet().plus(1).greaterThan(@type.maxlevel)
        return 0
      for cost in @sumCost @maxCostMet().plus(1)
        secs = cost.unit.estimateSecsUntilEarned cost.val
        if max.rawVal.lessThan secs
          max = {rawVal:secs, unit:cost.unit, now: @game.now.getTime()}
        cacheSafe &= cost.unit.isEstimateCacheable()
      max.cacheSafe = cacheSafe
      return max
  
    isUpgradable: (costPercent=undefined, useWatchedAt=false) ->
      # results are cached and updated only once every few seconds; may be out of date.
      # This function's used for the upgrade-available arrows, and without caching it'd be called once per
      # frame for every upgrade in the game. cpu profiler found it guilty of taking half our cpu when we
      # did that, so the delay's worth it.
      #
      # we could onUpdate-cache true results - false results may change to true at any time, but true
      # results can change to false only at an update. Complexity's not worth it, since true is the less
      # common case (most upgrades are *not* available at any given time). Actually used to do this, but
      # the code got ugly when we added separate periodic caching for falses.
      #
      # we could also predict when an update will be available, instead of rechecking every few seconds,
      # using estimateSecs. Complexity's not worth it yet, but if players start complaining about the
      # caching delay, this would reduce it.
      if useWatchedAt
        costPercent = new Decimal(costPercent ? 1).dividedBy @watchedDivisor()
      return @game.cache.upgradeIsUpgradable["#{@name}:#{costPercent}"] ?= @type.class == 'upgrade' and @isBuyable() and @maxCostMet(costPercent).greaterThan(0)
    isAutobuyable: ->
      return @watchedAt() > 0
    # default should match the default for maxCostMet
    isNewlyUpgradable: (costPercent=1) ->
      return @watchedAt() > 0 and @isUpgradable costPercent / @watchedDivisor()
  
    # TODO maxCostMet, buyMax that account for costFactor
    isBuyable: ->
      return @isCostMet() and @isVisible()
  
    buy: (num=1) ->
      if not @isCostMet()
        throw new Error "We require more resources"
      if not @isBuyable()
        throw new Error "Cannot buy that upgrade"
      num = Decimal.min num, @maxCostMet()
      $log.debug 'buy', @name, num
      @game.withSave =>
        for cost in @sumCost num
          util.assert cost.unit.count().greaterThanOrEqualTo(cost.val), "tried to buy more than we can afford. upgrade.maxCostMet is broken!", @name, name, cost
          util.assert cost.val.greaterThan(0), "zero cost from sumCost, yet cost was met?", @name, name, cost
          cost.unit._subtractCount cost.val
        count = @count()
        @_addCount num
        # limited to buying less than 1e300 upgrades at once. cost-factors, etc. ensure this is okay.
        # (not to mention 1e300 onBuy()s would take forever)
        for i in [0...num.toNumber()]
          for effect in @effect
            effect.onBuy count.plus(i + 1)
        return num
  
    buyMax: (percent) ->
      @buy @maxCostMet percent
  
    calcStats: (stats={}, schema={}) ->
      count = @count()
      for effect in @effect
        effect.calcStats stats, schema, count
      return stats
  
    statistics: ->
      @game.session.state.statistics?.byUpgrade?[@name] ? {}
  
    _watchedAtDefault: ->
      # watch everything by default - except mutagen
      @unit.tab?.name != 'mutagen'
    isManuallyHidden: ->
      return @watchedAt() < 0
    watchedAt: ->
      @game.session.state.watched ?= {}
      watched = @game.session.state.watched[@name] ? @_watchedAtDefault()
      if typeof(watched) == 'boolean'
        return if watched then 1 else 0
      return watched
    watchedDivisor: ->
      return Math.max @watchedAt(), 1
    watch: (state) ->
      @game.withUnreifiedSave =>
        @game.session.state.watched ?= {}
        # make savestates a little smaller
        if state != @_watchedAtDefault()
          @game.session.state.watched[@name] = state
        else
          delete @game.session.state.watched[@name]

angular.module('swarmApp').factory 'UpgradeType', -> class UpgradeType
  constructor: (data) ->
    _.extend this, data

angular.module('swarmApp').factory 'UpgradeTypes', (spreadsheetUtil, UpgradeType, util) -> class UpgradeTypes
  constructor: (@unittypes, upgrades=[]) ->
    @list = []
    @byName = {}
    for upgrade in upgrades
      @register upgrade

  register: (upgrade) ->
    util.assert upgrade.name, 'upgrade without a name', upgrade
    @list.push upgrade
    @byName[upgrade.name] = upgrade

  @parseSpreadsheet: (unittypes, effecttypes, data) ->
    rows = spreadsheetUtil.parseRows {name:['requires','cost','effect']}, data.data.upgrades.elements
    ret = new UpgradeTypes unittypes, (new UpgradeType(row) for row in rows when row.name)
    for upgrade in ret.list
      spreadsheetUtil.resolveList [upgrade], 'unittype', unittypes.byName
      spreadsheetUtil.resolveList upgrade.cost, 'unittype', unittypes.byName
      spreadsheetUtil.resolveList upgrade.requires, 'unittype', unittypes.byName
      spreadsheetUtil.resolveList upgrade.effect, 'unittype', unittypes.byName, {required:false}
      spreadsheetUtil.resolveList upgrade.effect, 'upgradetype', ret.byName, {required:false}
      spreadsheetUtil.resolveList upgrade.effect, 'type', effecttypes.byName
      for cost in upgrade.cost
        util.assert cost.val > 0, "upgradetype cost.val must be positive", cost
        if upgrade.maxlevel == 1 and not cost.factor
          cost.factor = 1
        util.assert cost.factor > 0, "upgradetype cost.factor must be positive", cost
    # resolve unittype.require.upgradetype, since upgrades weren't available when it was parsed. kinda hacky.
    for unittype in unittypes.list
      spreadsheetUtil.resolveList unittype.requires, 'upgradetype', ret.byName, {required:false}
    return ret

###*
 # @ngdoc service
 # @name swarmApp.upgrade
 # @description
 # # upgrade
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'upgradetypes', (UpgradeTypes, unittypes, effecttypes, spreadsheet) ->
  return UpgradeTypes.parseSpreadsheet unittypes, effecttypes, spreadsheet
