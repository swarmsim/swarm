'use strict'

###*
 # @ngdoc service
 # @name swarmApp.schedule
 # @description
 # # schedule
 # Service in the swarmApp.
###
angular.module('swarmApp').value 'dt', 1/10

angular.module('swarmApp').service 'schedule', ($timeout, $interval, session, _units_, dt) -> new class Schedule
  constructor: ->
    _units_.then (@units) =>
      @unpause()
  unpause: ->
    for unit in @units.list
      session.units[unit.name] ?= 0
    @ticker = $interval (=>@tick()), 1000 * dt
    @autosave = $interval (=>session.save()), 16666
  pause: ->
    $interval.cancel @ticker
    $interval.cancel @autosave
  tick: ->
    console.log 'tick'
    for unit in @units.list
      unit.tick session

angular.module('swarmApp').run (schedule) ->
  # runs on page load, start ticking
