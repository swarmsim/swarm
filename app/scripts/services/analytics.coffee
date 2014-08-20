'use strict'

###*
 # @ngdoc service
 # @name swarmApp.analytics
 # @description
 # # analytics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'analytics', ($rootScope, $analytics, game) ->
  console.log 'analytics loaded'
  $rootScope.$on 'save', (event) ->
    console.log 'save event'
    $analytics.eventTrack 'save', {}
