'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:unit
 # @description
 # # unit
###
angular.module('swarmApp').directive 'unit', (game, commands, $location) ->
  templateUrl: 'views/directive-unit.html'
  restrict: 'E'
  scope:
    cur: '='
  link: (scope, element, attrs) ->
    scope.game = game
    scope.commands = commands

    scope.form =
      mainBuynum: 1
    scope.mainBuynum = ->
      ret = Math.max 1, Math.floor scope.form.mainBuynum
      if _.isNaN ret
        ret = 1
      return ret
    scope.unitBuyTotal = (num) ->
      Math.min(num, scope.cur.maxCostMet()) * $scope.cur.stat 'twin', 1
    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

