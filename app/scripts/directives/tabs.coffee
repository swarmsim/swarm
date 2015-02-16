'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tabs
 # @description
 # # tabs
###
angular.module('swarmApp').directive 'tabs', (game, util, options, version, commands, env) ->
  templateUrl: 'views/tabs.html'
  scope:
    cur: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.tabs = game.tabs
    scope.options = options
    scope.game = game
    scope.isOffline = env.isOffline

    scope.filterVisible = (tab) -> tab.isVisible()

    scope.buyUpgrades = (upgrades, costPercent=1) ->
      commands.buyAllUpgrades upgrades:upgrades, percent:costPercent

    util.animateController scope, game:game, options:options
