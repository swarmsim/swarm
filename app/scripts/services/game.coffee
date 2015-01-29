'use strict'

angular.module('swarmApp').factory 'Cache', -> class Cache
  constructor: ->
    @onUpdate()

  onUpdate: ->
    @onTick()
    @stats = {}
    @eachCost = {}
    @eachProduction = {}
    @totalProduction = {}
    @upgradeTotalCost = {}
    @producerPathProdEach = {}

  onTick: ->
    @unitCount = {}
    @velocity = {}
    @upgradeMaxCostMet = {}

###*
 # @ngdoc service
 # @name swarmApp.game
 # @description
 # # game
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'Game', (unittypes, upgradetypes, achievements, util, $log, Upgrade, Unit, Achievement, Tab, Cache) -> class Game
  constructor: (@session) ->
    @_init()
  _init: ->
    @_units =
      list: _.map unittypes.list, (unittype) =>
        new Unit this, unittype
    @_units.byName = _.indexBy @_units.list, 'name'
    @_units.bySlug = _.indexBy @_units.list, (u) -> u.unittype.slug

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

    @tabs = Tab.buildTabs @_units.list

    @skippedMillis = 0
    @gameSpeed = 1
    @session.skippedMillis ?= 0

    for item in [].concat @_units.list, @_upgrades.list, @_achievements.list
      item._init()

    @cache = new Cache()

    # tick to reified-time, then to now. this ensures things explode here, instead of later, if they've gone back in time since saving
    delete @now
    @tick @session?.date?.reified
    @tick()

  diffMillis: ->
    @_realDiffMillis() * @gameSpeed + @skippedMillis
  _realDiffMillis: ->
    ret = @now.getTime() - @session.date.reified.getTime()
    util.assert ret >= 0, 'negative _realdiffmillis! went back in time somehow!'
    return ret
  diffSeconds: ->
    @diffMillis() / 1000

  skipMillis: (millis) ->
    @skippedMillis += millis
    @session.skippedMillis += millis
  skipDuration: (duration) ->
    @skipMillis duration.asMilliseconds()
  skipTime: (args...) ->
    @skipDuration moment.duration args...

  setGameSpeed: (speed) ->
    @reify()
    @gameSpeed = speed

  totalSkippedMillis: ->
    @session.skippedMillis
  totalSkippedDuration: ->
    moment.duration @totalSkippedMillis()
  dateStarted: ->
    @session.date.started
  momentStarted: ->
    moment @dateStarted()

  tick: (now=new Date(), skipExpire=false) ->
    util.assert now, "can't tick to undefined time", now
    if (not @now) or @now <= now
      @now = now
      @cache.onTick()
    else
      # system clock problem! don't whine for small timing errors, but don't update the clock either.
      # TODO I hope this accounts for DST
      diffMillis = @now.getTime() - now.getTime()
      util.assert diffMillis <= 120 * 1000, "tick tried to go back in time. System clock problem?", @now, now, diffMillis

  elapsedStartMillis: ->
    @now.getTime() - @session.date.started.getTime()
  timestampMillis: ->
    @elapsedStartMillis() + @totalSkippedMillis()

  unit: (unitname) ->
    if _.isUndefined unitname
      return undefined
    if not _.isString unitname
      # it's a unittype?
      unitname = unitname.name
    @_units.byName[unitname]
  unitBySlug: (unitslug) ->
    @_units.bySlug[unitslug]
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
  getNewlyUpgradableUnits: ->
    (u for u in @unitlist() when u.isNewlyUpgradable() and u.isVisible())

  upgrade: (name) ->
    if not _.isString name
      name = name.name
    @_upgrades.byName[name]
  upgrades: ->
    _.clone @_upgrades.byName
  upgradelist: ->
    _.clone @_upgrades.list
  availableUpgrades: (costPercent=undefined) ->
    (u for u in @upgradelist() when u.isVisible() and u.isUpgradable costPercent)
  availableAutobuyUpgrades: (costPercent=undefined) ->
    (u for u in @availableUpgrades(costPercent) when u.isAutobuyable())
  newUpgrades: (costPercent=undefined) ->
    (u for u in @upgradelist() when u.isVisible() and u.isNewlyUpgradable costPercent)
  ignoredUpgrades: ->
    (u for u in @upgradelist() when u.isVisible() and u.isIgnored())
  unignoredUpgrades: ->
    (u for u in @upgradelist() when u.isVisible() and not u.isIgnored())

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
  reify: (skipSeconds=0) ->
    secs = @diffSeconds()
    counts = @counts secs
    _.extend @session.unittypes, counts
    @skippedMillis = 0
    @session.skippedMillis += @diffMillis() - @_realDiffMillis()
    @session.date.reified = @now
    @cache.onUpdate()
    util.assert 0 == @diffSeconds(), 'diffseconds != 0 after reify!'

  save: ->
    @withSave ->

  importSave: (encoded, transient=false) ->
    @session.importSave encoded
    # Force-clear various caches.
    @_init()
    # No errors - successful import. Save now by default, so refreshing the page uses the import.
    if not transient
      @session.save()

  # A common pattern: change something (reifying first), then save the changes.
  # Use game.withSave(myFunctionThatChangesSomething) to do that.
  withSave: (fn) ->
    @reify()
    ret = fn()
    @session.save()
    @cache.onUpdate()
    return ret

  reset: (butDontSave=false) ->
    @session.reset()
    @_init()
    for unit in @unitlist()
      unit._setCount unit.unittype.init or 0
    if not butDontSave
      @save()

  ascendEnergySpent: ->
    energy = @unit 'energy'
    return energy.spent()
  ascendCost: ->
    spent = @ascendEnergySpent()
    ascends = @unit('ascension').count()
    ascendPenalty = Decimal.pow 1.2, ascends
    #return Math.ceil 999999 / (1 + spent/50000)
    # initial cost 5 million, halved every 50k spent, increases 20% per past ascension
    return ascendPenalty.times(5e6).dividedBy(Decimal.pow 2, spent.dividedBy 50000).ceil()
  ascendCostCapDiff: ->
    return @ascendCost().minus @unit('energy').capValue()
  ascendCostPercent: ->
    Math.min 1, @unit('energy').count().dividedBy @ascendCost()
  ascendCostDurationSecs: ->
    energy = @unit 'energy'
    cost = @ascendCost()
    if cost <= energy.capValue()
      return energy.estimateSecs cost
  ascendCostDurationMoment: ->
    if (secs=@ascendCostDurationSecs())?
      return moment.duration secs, 'seconds'
  ascend: ->
    @withSave =>
      # hardcode ascension bonuses. TODO: spreadsheetify
      premutagen = @unit 'premutagen'
      mutagen = @unit 'mutagen'
      ascension = @unit 'ascension'
      mutagen._addCount premutagen.count()
      premutagen._setCount 0
      ascension._addCount 1
      # do not use @reset(): we don't want achievements, etc. reset
      @_init()
      for unit in @unitlist()
        if unit.tab?.name != 'mutagen'
          unit._setCount unit.unittype.init
      for upgrade in @upgradelist()
        if upgrade.unit.tab?.name != 'mutagen'
          upgrade._setCount 0

  respecRate: ->
    0.70
  respecSpent: ->
    mutagen = @unit 'mutagen'
    # upgrade costs are weird - upgrade costs rely on other upgrades, which breaks spending tracking.
    # ignore them, relying on the mutateHidden upgrade for the true cost.
    ignores = {}
    for up in mutagen.upgrades.list
      ignores[up.name] = true
    # Upgrades come with a free(ish) unit too, so remove their cost. (Mostly for unit tests, doesn't really matter.)
    return mutagen.spent(ignores).minus(@upgrade('mutatehidden').count())
  respecConfirm: ->
    # TODO move me to a controller or something
    if window.confirm "Are you sure you want to respec? You will only be refunded #{@respecRate() * 100}% of the mutagen you've spent."
      @respec()
  respec: ->
    mutagen = @unit 'mutagen'
    spent = @respecSpent()
    for resource in mutagen.spentResources()
      resource._setCount 0
      if resource._visible?
        resource._visible = false
    mutagen._addCount spent.times(@respecRate()).floor()
    util.assert mutagen.spent().isZero(), "respec didn't refund all mutagen!"

angular.module('swarmApp').factory 'game', (Game, session) ->
  new Game session
