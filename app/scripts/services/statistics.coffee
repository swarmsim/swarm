'use strict'

###*
 # @ngdoc service
 # @name swarmApp.statistics
 # @description
 # # statistics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'StatisticsListener', (util, $log) -> class StatisticsListener
  constructor: (@session, @scope) ->
    @_init()

  _init: ->
    stats = @session.state.statistics ?= {}
    stats.byUnit ?= {}
    stats.byUpgrade ?= {}
    stats.clicks ?= 0
  
  push: (cmd) ->
    stats = @session.state.statistics
    stats.clicks += 1
    if cmd.unitname?
      ustats = stats.byUnit[cmd.unitname]
      if not ustats?
        ustats = stats.byUnit[cmd.unitname] = {clicks:0,num:0,twinnum:0,elapsedFirst:cmd.elapsed}
        @scope.$emit 'buyFirst', cmd
      ustats.clicks += 1
      try
        ustats.num = new Decimal(ustats.num).plus(cmd.num)
        ustats.twinnum = new Decimal(ustats.twinnum).plus(cmd.twinnum)
      catch e
        $log.warn 'statistics corrupt for unit, resetting', cmd.unitname, ustats, e
        ustats.num = new Decimal cmd.num
        ustats.twinnum = new Decimal cmd.twinnum
    if cmd.upgradename?
      ustats = stats.byUpgrade[cmd.upgradename]
      if not ustats?
        ustats = stats.byUpgrade[cmd.upgradename] = {clicks:0,num:0,elapsedFirst:cmd.elapsed}
        @scope.$emit 'buyFirst', cmd
      ustats.clicks += 1
      try
        ustats.num = new Decimal(ustats.num).plus(cmd.num)
      catch e
        $log.warn 'statistics corrupt for upgrade, resetting', cmd.upgradename, ustats, e
        ustats.num = new Decimal cmd.num
    delete cmd.now
    delete cmd.unit
    delete cmd.upgrade

  listen: (scope) ->
    scope.$on 'reset', =>
      @_init()
    # listening for each command is no longer necessary, this is called directly from command() to ensure it's saved

angular.module('swarmApp').factory 'statistics', (session, StatisticsListener, $rootScope) ->
  stats = new StatisticsListener session, $rootScope
  stats.listen $rootScope
  return stats
