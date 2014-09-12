'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tabs
 # @description
 # # tabs
###
angular.module('swarmApp').directive 'tabs', (game, util, options, hotkeys) ->
  templateUrl: 'views/tabs.html'
  scope:
    cur: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.tabs = game.tabs
    scope.filterVisible = (tab) -> tab.isVisible()
    scope.hotkeys = hotkeys

    util.animateController scope, game:game, options:options
