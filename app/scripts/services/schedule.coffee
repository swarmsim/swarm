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
    @ticker = $interval (=>@tick()), 1000 * dt
    @autosave = $interval (=>session.save()), 16666
    @isPaused = false
  pause: ->
    $interval.cancel @ticker
    $interval.cancel @autosave
    @isPaused = true
  tick: ->
    #console.log 'tick'
    for unittype in @unittypes.list
      unittype.tick session
