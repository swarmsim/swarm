'use strict'

###*
 # @ngdoc service
 # @name swarmApp.schedule
 # @description
 # # schedule
 # Service in the swarmApp.
###
angular.module('swarmApp').value 'dt', 1/10

angular.module('swarmApp').service 'schedule', ($timeout, $interval, session, _unittypes_, dt) -> new class Schedule
  constructor: ->
    @isPaused = true
    _unittypes_.then (@unittypes) =>
      console.log 'loaded units', @unittypes
      @unpause()
  unpause: ->
    for unittype in @unittypes.list
      session.unittypes[unittype.name] ?= 0
    @ticker = $interval (=>@safeTickAll()), 1000 * dt
    @autosave = $interval (=>session.save()), 16666
    @isPaused = false
  pause: ->
    $interval.cancel @ticker
    $interval.cancel @autosave
    @isPaused = true
  elapsedSinceLastTick: (lastTicked=session.date.lastTicked, now=new Date()) ->
    ret = {}
    ret.rawMillis = now.getTime() - lastTicked.getTime()
    ret.rawSeconds = ret.rawMillis / 1000
    ret.ticks = Math.floor ret.rawSeconds / dt
    ret.seconds = ret.ticks * dt
    ret.millis = Math.floor ret.ticks * dt * 1000
    ret.lastTicked = new Date lastTicked.getTime() + ret.millis
    console.assert (not ret.lastTicked <= now), "lastTicked is later than now?!"
    return ret
  safeTickAll: ->
    try
      @tickAll()
    catch e
      console.error 'tick() broke, pausing. Refresh to resume.'
      @pause()
      throw e
  tickAll: ->
    elapsed = @elapsedSinceLastTick()
    session.date.lastTicked = elapsed.lastTicked
    if elapsed.ticks > 5
      console.log "multitick", elapsed?.ticks, elapsed
    # max 1 day's worth of ticks compensated
    # TODO: pascal's triangle can compute this instantly
    #ticks = Math.min elapsed.ticks, 1/dt * 60 * 60 * 24
    ticks = Math.min elapsed.ticks, 1000
    for tick in [0...ticks]
      @tick()
  tick: ->
    #console.log 'tick'
    for unittype in @unittypes.list
      unittype.tick session
