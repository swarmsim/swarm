'use strict'

###*
 # @ngdoc service
 # @name swarmApp.command
 # @description
 # # command
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'commands', (util, $rootScope) -> new class Commands
  constructor: ->

  _emit: (name, params) ->
    util.assert !params.name?, 'command has a name already?'
    params.name = name
    #$rootScope.$emit "command:#{name}", params #this isn't actually used
    $rootScope.$emit "command", params

  buyUnit: (unit, num) ->
    bought = unit.buy num
    @_emit 'buyUnit',
      unit:unit
      # names are included for easier jsonification
      unitname:unit.name
      attempt:num
      num:bought.num
      twinnum:bought.twinnum

  buyMaxUnit: (unit) ->
    bought = unit.buyMax()
    @_emit 'buyMaxUnit',
      unit:unit
      unitname:unit.name
      num:bought.num
      twinnum:bought.twinnum

  buyUpgrade: (upgrade) ->
    num = upgrade.buy() #will always be 1. TODO: support multibuying upgrades
    @_emit 'buyUpgrade',
      upgrade:upgrade
      upgradename:upgrade.name
      num:num
