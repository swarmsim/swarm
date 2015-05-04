'use strict'

###*
 # @ngdoc service
 # @name swarmApp.command
 # @description
 # # command
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'commands', (util, $rootScope, $log, loginApi, statistics) -> new class Commands
  constructor: ->

  _setUndo: (game, opts={}) ->
    @_undo = _.extend {}, opts,
      state: game.session.exportSave()
      date: game.now
      game: game

  undo: ->
    if not @_undo?.state
      throw new Error 'no undostate available'
    state = @_undo.state
    @_setUndo @_undo.game, isRedo:true
    @_undo.game.importSave state, false

  _emit: (game, name, params) ->
    util.assert !params.name?, 'command has a name already?'
    params.name = name
    #$rootScope.$emit "command:#{name}", params #this isn't actually used
    statistics.push params
    $rootScope.$emit "command", params
    loginApi.saveCommand params
    game.session.save()

  buyUnit: (opts) ->
    unit = opts.unit
    num = opts.num
    @_setUndo unit.game
    bought = unit.buy num
    @_emit unit.game, 'buyUnit',
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
    @_setUndo unit.game
    bought = unit.buyMax opts.percent
    @_emit unit.game, 'buyMaxUnit',
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
    @_setUndo upgrade.game
    num = upgrade.buy opts.num
    @_emit upgrade.game, 'buyUpgrade',
      upgrade:upgrade
      upgradename:upgrade.name
      now:upgrade.game.now
      elapsed:upgrade.game.elapsedStartMillis()
      num:num
      ui:opts.ui

  buyMaxUpgrade: (opts) ->
    upgrade = opts.upgrade
    @_setUndo upgrade.game
    num = upgrade.buyMax opts.percent
    @_emit upgrade.game, 'buyMaxUpgrade',
      upgrade:upgrade
      upgradename:upgrade.name
      now:upgrade.game.now
      elapsed:upgrade.game.elapsedStartMillis()
      num:num
      percent:opts.percent
      ui:opts.ui

  buyAllUpgrades: (opts) ->
    upgrades = opts.upgrades
    if upgrades.length
      game = upgrades[0].game
      @_setUndo game
      for upgrade in upgrades
        num = upgrade.buyMax opts.percent
        @_emit game, 'buyMaxUpgrade',
          upgrade:upgrade
          upgradename:upgrade.name
          now:upgrade.game.now
          elapsed:upgrade.game.elapsedStartMillis()
          num:num
          percent:opts.percent
          ui:'buyAllUpgrades'
      @_emit game, 'buyAllUpgrades',
        now:upgrades[0].game.now
        elapsed:upgrades[0].game.elapsedStartMillis()
        percent:opts.percent

  ascend: (opts) ->
    game = opts.game
    @_setUndo game
    game.ascend()
    @_emit game, 'ascension',
      now: game.now
      unit: game.unit 'ascension'
      unitname: 'ascension'
      num: 1
      twinnum: 1
      elapsed: game.elapsedStartMillis()

  respec: (opts) ->
    game = opts.game
    @_setUndo game
    game.respec()
    @_emit game, 'respec',
      now: game.now
      elapsed: game.elapsedStartMillis()

  respecFree: (opts) ->
    game = opts.game
    @_setUndo game
    game.respecFree()
    @_emit game, 'respec',
      now: game.now
      elapsed: game.elapsedStartMillis()

  adminEdit: (opts) ->
    # saves all changes that have been made to the user, without questioning them. Used for admin debugging.
    game = opts.game
    @_emit game, 'adminEdit',
      now: game.now
      state: game.session.state
      elapsed: game.elapsedStartMillis()

  setPreferences: (opts) ->
    # Set preferences data: options, achievement sorting, watched upgrades - anything that can be blindly synced without the potential for cheating
    game = opts.game
    @_emit game, 'setPreferences',
      options: opts.options
      achievementsShown: opts.achievementsShown
      watched: opts.watched
      idOnServer: opts.idOnServer
      now: game.now
      elapsed: game.elapsedStartMillis()
    
  earnAchievement: (opts) ->
    achievement = opts.achievement
    game = achievement.game
    achievement._earn opts.elapsed
    @_emit game, 'setPreferences',
      achievement: achievement
      achievementName: achievement.name
      now: game.now
      elapsed: opts.elapsed ? game.elapsedStartMillis()

  reset: (opts) ->
    game = opts.game
    if opts.undoable ? true
      @_setUndo game
    # get params *before* resetting
    params =
      now: game.now
    game.reset()
    @_emit game, 'reset', params
