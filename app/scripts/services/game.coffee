'use strict'

###*
 # @ngdoc service
 # @name swarmApp.game
 # @description
 # # game
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'Game', (unittypes, upgradetypes, achievements, util, $log, Upgrade, Unit, Achievement, Tab) -> class Game
  constructor: (@session) ->
    @_init()
  _init: ->
    @_units =
      list: _.map unittypes.list, (unittype) =>
        new Unit this, unittype
    @_units.byName = _.indexBy @_units.list, 'name'
    @_units.byLabel = _.indexBy @_units.list, (u) -> u.unittype.label

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
    @tick()

  diffMillis: ->
    @_realDiffMillis() * @gameSpeed + @skippedMillis
  _realDiffMillis: ->
    @now.getTime() - @session.date.reified.getTime()
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

  tick: (now=new Date()) ->
    # TODO I hope this accounts for DST
    util.assert now, "can't tick to undefined time", now
    util.assert (not @now) or @now <= now, "tick tried to go back in time. System clock problem?", @now, now
    @now = now

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
  unitByLabel: (unitlabel) ->
    @_units.byLabel[unitlabel]
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
    util.assert 0 == @diffSeconds(), 'diffseconds != 0 after reify!'

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

  reset: (butDontSave=false) ->
    @session.reset()
    @_init()
    for unit in @unitlist()
      unit._setCount unit.unittype.init
    if not butDontSave
      @save()

angular.module('swarmApp').factory 'game', (Game, session) ->
  new Game session
