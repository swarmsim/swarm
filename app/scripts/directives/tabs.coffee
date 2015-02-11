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

    scope.feedbackUrl = ->
      game.session.feedbackUrl()

    scope.buyUpgrades = (upgrades, costPercent=1) ->
      commands.buyAllUpgrades upgrades:upgrades, percent:costPercent
    scope.ignoreUpgrades = (upgrades) ->
      for upgrade in upgrades
        upgrade.viewNewUpgrades()
    scope.unignoreUpgrades = (upgrades) ->
      for upgrade in upgrades
        upgrade.unignore()

    util.animateController scope, game:game, options:options
