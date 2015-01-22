'use strict'

###*
 # @ngdoc service
 # @name swarmApp.command
 # @description
 # # command
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'commands', (util, $rootScope, $log) -> new class Commands
  constructor: ->

  _emit: (name, params) ->
    util.assert !params.name?, 'command has a name already?'
    params.name = name
    #$rootScope.$emit "command:#{name}", params #this isn't actually used
    $rootScope.$emit "command", params

  buyUnit: (opts) ->
    unit = opts.unit
    num = opts.num
    bought = unit.buy num
    @_emit 'buyUnit',
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
    unit = opts.unit
    bought = unit.buyMax opts.percent
    @_emit 'buyMaxUnit',
      unit:unit
      unitname:unit.name
      now:unit.game.now
      elapsed:unit.game.elapsedStartMillis()
      num:bought.num
      twinnum:bought.twinnum
      percent:opts.percent
      ui:opts.ui

  buyUpgrade: (opts) ->
    upgrade = opts.upgrade
    num = upgrade.buy opts.num
    @_emit 'buyUpgrade',
      upgrade:upgrade
      upgradename:upgrade.name
      now:upgrade.game.now
      elapsed:upgrade.game.elapsedStartMillis()
      num:num
      ui:opts.ui

  buyMaxUpgrade: (opts) ->
    upgrade = opts.upgrade
    num = upgrade.buyMax opts.percent
    @_emit 'buyMaxUpgrade',
      upgrade:upgrade
      upgradename:upgrade.name
      now:upgrade.game.now
      elapsed:upgrade.game.elapsedStartMillis()
      num:num
      percent:opts.percent
      ui:opts.ui

  buyAllUpgrades: (opts) ->
    upgrades = opts.upgrades
    for upgrade in upgrades
      num = upgrade.buyMax opts.percent
      @_emit 'buyMaxUpgrade',
        upgrade:upgrade
        upgradename:upgrade.name
        now:upgrade.game.now
        elapsed:upgrade.game.elapsedStartMillis()
        num:num
        percent:opts.percent
        ui:'buyAllUpgrades'
    if upgrades.length
      @_emit 'buyAllUpgrades',
        now:upgrades[0].game.now
        elapsed:upgrades[0].game.elapsedStartMillis()
        percent:opts.percent

  ascend: (opts) ->
    game = opts.game
    game.ascend()
    @_emit 'ascension',
      now: game.now
      elapsed: game.elapsedStartMillis()
