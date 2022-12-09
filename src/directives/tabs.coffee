'use strict'
import * as views from '../views'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tabs
 # @description
 # # tabs
###
angular.module('swarmApp').directive 'tabs', (game, util, options, version, commands, hotkeys) ->
  template: views.tabs
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

    scope.buyAllUpgrades = ->
      scope.buyUpgrades(game.availableAutobuyUpgrades())
    scope.buyCheapestUpgrades = ->
      scope.buyUpgrades(game.availableAutobuyUpgrades(0.25), 0.25)

    hotkeys.bindTo(scope)
    .add
      combo: 'z'
      description: 'Undo the last action'
      callback: () -> scope.undo()
    .add
      combo: 'alt+a'
      description: 'Buy all available upgrades'
      callback: () -> scope.buyAllUpgrades()
    .add
      combo: 'alt+c'
      description: 'Buy cheapest available upgrades'
      callback: () -> scope.buyCheapestUpgrades()
      
