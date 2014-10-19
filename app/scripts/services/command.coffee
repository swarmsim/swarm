'use strict'

###*
 # @ngdoc service
 # @name swarmApp.command
 # @description
 # # command
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'commands', (util, $rootScope, session) -> new class Commands
  constructor: ->

  _doCommand: (name, opts, fn) ->
    undoExport = session.exportSave()
    params = fn()
    params.undoExport = undoExport
    @_emit name, params
  _emit: (name, params) ->
    util.assert !params.name?, 'command has a name already?'
    params.name = name
    #$rootScope.$emit "command:#{name}", params #this isn't actually used
    $rootScope.$emit "command", params

  buyUnit: (opts) ->
    @_doCommand 'buyUnit', opts, =>
      unit = opts.unit
      num = opts.num
      bought = unit.buy num
      unit:unit
      # names are included for easier jsonification
      unitname:unit.name
      now:unit.game.now
      elapsed:unit.game.elapsedStartMillis()
      attempt:num
      num:bought.num
      twinnum:bought.twinnum
      ui:opts.ui

  buyMaxUnit: (opts) ->
    @_doCommand 'buyMaxUnit', opts, =>
      unit = opts.unit
      bought = unit.buyMax opts.percent
      unit:unit
      unitname:unit.name
      now:unit.game.now
      elapsed:unit.game.elapsedStartMillis()
      num:bought.num
      twinnum:bought.twinnum
      percent:opts.percent
      ui:opts.ui

  buyUpgrade: (opts) ->
    @_doCommand 'buyUpgrade', opts, =>
      upgrade = opts.upgrade
      num = upgrade.buy opts.num
      upgrade:upgrade
      upgradename:upgrade.name
      now:upgrade.game.now
      elapsed:upgrade.game.elapsedStartMillis()
      num:num
      ui:opts.ui

  buyMaxUpgrade: (opts) ->
    @_doCommand 'buyMaxUpgrade', opts, =>
      upgrade = opts.upgrade
      num = upgrade.buyMax opts.percent
      upgrade:upgrade
      upgradename:upgrade.name
      now:upgrade.game.now
      elapsed:upgrade.game.elapsedStartMillis()
      num:num
      percent:opts.percent
      ui:opts.ui
