'use strict'

angular.module('swarmApp').factory 'Upgrade', (util, Effect, $log) -> class Upgrade
  constructor: (@game, @type) ->
    @name = @type.name
    @unit = util.assert @game.unit @type.unittype
    @_totalCost = util.memoize @_totalCost
    @_lastUpgradeSeen = 0
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
  # TODO refactor counting to share with unit
  count: ->
    ret = @game.session.upgrades[@name] ? 0
    if _.isNaN ret
      util.error "count is NaN! resetting to zero. #{@name}"
      ret = 0
    # we shouldn't ever exceed maxlevel, but just in case...
    if @type.maxlevel
      ret = Decimal.min @type.maxlevel, ret
    return new Decimal ret
  _setCount: (val) ->
    @game.session.upgrades[@name] = new Decimal val
    util.clearMemoCache @_totalCost, @unit._stats, @unit._eachCost
    for u in @unit.upgrades.list
      util.clearMemoCache u._totalCost
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
    if @_visible
      return true
    return @_visible = @_isVisible()
  _isVisible: ->
    if @count().greaterThan 0
      return true
    for require in @requires
      if require.val.greaterThan require.unit.count()
        return false
    return true
  totalCost: -> @_totalCost @count().plus @unit.stat 'upgradecost', 0
  _totalCost: (count=@count().plus @unit.stat 'upgradecost', 0)->
    _.map @cost, (cost) =>
      total = _.clone cost
      total.val = total.val.plus Decimal.pow total.factor, count
      return total
  sumCost: (num, startCount) ->
    costs0 = @_totalCost startCount
    _.map @_totalCost(startCount), (cost0) ->
      cost = _.clone cost0
      # special case: 1 / (1 - 1) == boom
      if cost.factor.equals 1
        cost.val = cost.val.times num
      else
        # see maxCostMet for O(1) summation formula derivation.
        # cost.val *= (1 - Math.pow cost.factor, num) / (1 - cost.factor)
        cost.val = cost.val.times new Decimal(1).minus(Decimal.pow cost.factor, num).dividedBy(new Decimal(1).minus cost.factor)
      return cost
  isCostMet: ->
    return @maxCostMet().greaterThan 0

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
    max = new Decimal Infinity
    if @type.maxlevel
      max = new Decimal(@type.maxlevel).minus(@count())
    for cost in @totalCost()
      util.assert cost.val.greaterThan(0), 'upgrade cost <= 0', @name, this
      if cost.factor.equals(1) #special case: math.log(1) == 0; x / math.log(1) == boom
        m = cost.unit.count().dividedBy(cost.val)
      else
        #m = Math.log(1 - (cost.unit.count() * percent) * (1 - cost.factor) / cost.val) / Math.log cost.factor
        m = Decimal.ONE.minus(cost.unit.count().times(percent).times(Decimal.ONE.minus cost.factor).dividedBy(cost.val)).log().dividedBy(cost.factor.log())
      max = Decimal.min max, m
      #$log.debug 'iscostmet', @name, cost.unit.name, m, max, cost.unit.count(), cost.val
    return max.floor()

  costMetPercent: ->
    costOfMet = _.indexBy @sumCost(@maxCostMet()), (c) -> c.unit.name
    max = new Decimal Infinity
    if @type.maxlevel? and @maxCostMet().plus(1).greaterThan(@type.maxlevel)
      return Decimal.ONE
    for cost in @sumCost @maxCostMet().plus(1)
      count = cost.unit.count().minus costOfMet[cost.unit.name].val
      val = cost.val.minus costOfMet[cost.unit.name].val
      max = Decimal.min max, (count.dividedBy val)
    return Decimal.min 1, Decimal.max 0, max

  # TODO merge with costMetPercent
  estimateSecs: ->
    costOfMet = _.indexBy @sumCost(@maxCostMet()), (c) -> c.unit.name
    max = {val:0, unit:null}
    if @type.maxlevel? and @maxCostMet().plus(1).greaterThan(@type.maxlevel)
      return 0
    for cost in @sumCost @maxCostMet().plus(1)
      secs = cost.unit.estimateSecs cost.val
      if max.val < secs
        max = {val:secs, unit:cost.unit}
    return max

  viewNewUpgrades: ->
    if @isVisible() and util.isWindowFocused true
      @_lastUpgradeSeen = @maxCostMet()
  isNewlyUpgradable: (costPercent=undefined) ->
    #@_lastUpgradeSeen < @maxCostMet()
    @isUpgradable(costPercent) and not @isIgnored()
  isIgnored: ->
    @_lastUpgradeSeen and !@_lastUpgradeSeen.equals(0)
  unignore: ->
    @_lastUpgradeSeen = new Decimal 0
  isUpgradable: (costPercent=undefined) ->
    #@_lastUpgradeSeen < @maxCostMet()
    @isBuyable() and @maxCostMet(costPercent).greaterThan(0) and @type.class == 'upgrade'

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
      @viewNewUpgrades()
      return num

  buyMax: (percent) ->
    @buy @maxCostMet percent

  calcStats: (stats={}, schema={}) ->
    count = @count()
    for effect in @effect
      effect.calcStats stats, schema, count
    return stats


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
