'use strict'

###*
 # @ngdoc service
 # @name swarmApp.schedule
 # @description
 # # schedule
 # Service in the swarmApp.
###
angular.module('swarmApp').service 'schedule', ($timeout, $interval, session) -> new class Schedule
  constructor: ->
    @unpause()
  unpause: ->
    @ticker = $interval (=>@tick()), 1000
  pause: ->
    $interval.cancel @ticker
  tick: ->
    console.log 'tick'
    session.food += session.drone

angular.module('swarmApp').run (schedule) ->
  # runs on page load, start ticking
