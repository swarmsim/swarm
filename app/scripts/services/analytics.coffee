'use strict'

###*
 # @ngdoc service
 # @name swarmApp.analytics
 # @description
 # # analytics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'analytics', ($rootScope, $analytics, env, game) ->
  # no analytics during testing
  if env == 'test'
    return
  #console.log 'analytics loaded'
  $rootScope.$on 'save', (event, args) ->
    console.log 'save event'
    #$analytics.eventTrack 'save', {}
  $rootScope.$on 'command', (event, args) ->
    console.log 'command event', event.name, args.name, args
    #$analytics.eventTrack 'command', {}
