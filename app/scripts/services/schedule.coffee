'use strict'

###*
 # @ngdoc service
 # @name swarmApp.schedule
 # @description
 # # schedule
 # Service in the swarmApp.
###
angular.module('swarmApp').service 'schedule', ($timeout, $interval, session, _units_) -> new class Schedule
  constructor: ->
    _units_.then (@units) =>
      console.log 'starting ticks', @units
      for unit in @units.list
        session.units[unit.name] ?= 0
      console.log 'session', session
      @unpause()
  unpause: ->
    @ticker = $interval (=>@tick()), 1000
  pause: ->
    $interval.cancel @ticker
  tick: ->
    console.log 'tick'
    for unit in @units.list
      unit.tick session

angular.module('swarmApp').run (schedule) ->
  # runs on page load, start ticking
