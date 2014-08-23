'use strict'

###*
 # @ngdoc service
 # @name swarmApp.statistics
 # @description
 # # statistics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'StatisticsListener', (util) -> class StatisticsListener
  constructor: (@session) ->
    # Transient. TODO: persist this separately from session, it can get big
    @replay = []
    @_init()

  _init: ->
    stats = @session.statistics ?= {}
    stats.byUnit ?= {}
    stats.byUpgrade ?= {}
    stats.clicks ?= 0
  
  jsonReplay: ->
    JSON.stringify @replay

  compressedReplay: ->
    LZString.compressToBase64 @jsonReplay()

  push: (cmd) ->
    stats = @session.statistics
    stats.clicks += 1
    if cmd.unitname?
      ustats = stats.byUnit[cmd.unitname] ?= {clicks:0,num:0,twinnum:0,elapsedFirst:cmd.elapsed}
      ustats.clicks += 1
      ustats.num += cmd.num
      ustats.twinnum += cmd.twinnum
    if cmd.upgradename?
      ustats = stats.byUpgrade[cmd.upgradename] ?= {clicks:0,num:0,elapsedFirst:cmd.elapsed}
      ustats.clicks += 1
      ustats.num += cmd.num
    @session.save() #TODO session is saved twice for every command, kind of lame
    delete cmd.now
    delete cmd.unit
    delete cmd.upgrade
    @replay.push cmd

  listen: (scope) ->
    scope.$on 'reset', => @_init()
    scope.$on 'command', (event, cmd) =>
      console.log 'statistics', event, cmd
      @push cmd

angular.module('swarmApp').factory 'statistics', (session, StatisticsListener, $rootScope) ->
  stats = new StatisticsListener session
  stats.listen $rootScope
  return stats
