'use strict'

###*
 # @ngdoc service
 # @name swarmApp.favico
 # @description
 # # favico
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'favico', (game, env, $rootScope, $log) ->
  if window.Favico?
    ret = new class FavicoService
      constructor: ->
        @instance = new Favico
          animation: 'none'
        @lastcount = 0
      update: ->
        units = game.getNewlyUpgradableUnits()
        count = units.length
        if count != @lastcount
          $log.debug 'favicon update', stale:@lastcount, fresh:count, units:units
          if count > 0
            @instance.badge count
          else
            @instance.reset()
        @lastcount = count
  else
    # unit tests refuse to load favico for some reason
    ret = new class UnitTestFavicoService
      constructor: ->
      update: ->
  $rootScope.$on 'tick', ->
    ret.update()
  return ret
