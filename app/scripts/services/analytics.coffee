'use strict'

###*
 # @ngdoc service
 # @name swarmApp.analytics
 # @description
 # # analytics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'analytics', ($rootScope, $analytics, env, game, version) ->
  # no analytics during testing
  if env == 'test'
    return
  #console.log 'analytics loaded'
  #window.ga 'set', 'appVersion', version

  $rootScope.$on 'select', (event, args) ->
    name = args?.unit?.name ? '#back-button'
    $analytics.pageTrack "/unit/#{name}"

  $rootScope.$on 'save', (event, args) ->
    #console.log 'save event'
    #$analytics.eventTrack 'save', {}

  $rootScope.$on 'command', (event, cmd) ->
    #console.log 'command event', event.name, cmd.name, cmd
    $analytics.eventTrack cmd.name,
      category:'command'
      label:cmd.unitname ? cmd.upgradename
      value:cmd.twinnum ? cmd.num

  $rootScope.$on 'buyFirst', (event, cmd) ->
    $analytics.eventTrack "buyFirst:#{cmd.name}",
      category:'buyFirst'
      label:cmd.unitname ? cmd.upgradename
      value:cmd.elapsed

  $rootScope.$on 'reset', (event) ->
    $analytics.eventTrack 'reset',
      category:'reset'

  $rootScope.$on 'import', (event, args) ->
    $analytics.eventTrack 'import',
      category:'import'
      value:if args.success then 1 else 0
