'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tabs
 # @description
 # # tabs
###
angular.module('swarmApp').directive 'tabs', (game, util, options, version, commands, hotkeys, $location) ->
  templateUrl: 'views/tabs.html'
  scope:
    cur: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.tabs = game.tabs
    scope.options = options
    scope.game = game

    scope.filterVisible = (tab) -> tab.isVisible()

    scope.buyUpgrades = (upgrades, costPercent=1) ->
      # don't buy zero upgrades, it would invalidate undo. #628
      if upgrades.length > 0
        commands.buyAllUpgrades upgrades:upgrades, percent:costPercent

    util.animateController scope, game:game, options:options

    scope.undo = ->
      if scope.isUndoable()
        commands.undo()
    scope.secondsSinceLastAction = ->
      return (game.now.getTime() - (commands._undo?.date?.getTime?() ? 0)) / 1000
    scope.undoLimitSeconds = 30
    scope.isRedo = ->
      commands._undo?.isRedo
    scope.isUndoable = ->
      return scope.secondsSinceLastAction() < scope.undoLimitSeconds and not scope.isRedo()
      
    scope.showHotkeys = ->
      hotkeys.toggleCheatSheet()
    hotkeys.bindTo(scope).add
      combo: 'ctrl+z'
      description: 'Undo (within 30 seconds)'
      callback: => scope.undo()
    tabkeys =
      meat: 'alt+1'
      larva: 'alt+2'
      territory: 'alt+3'
      energy: 'alt+4'
      mutagen: 'alt+5'
    for name, combo of tabkeys then do (name, combo) =>
      tab = scope.tabs.byName[name]
      if tab?.isVisible()
        hotkeys.bindTo(scope).add
          combo: combo
          description: "Select #{tab.leadunit.unittype.label} tab"
          callback: => $location.url tab.url()
