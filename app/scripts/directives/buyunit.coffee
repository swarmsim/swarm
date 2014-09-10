'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:buyunit
 # @description
 # # buyunit
###
angular.module('swarmApp').directive 'buyunit', (game, commands) ->
  templateUrl: 'views/buyunit.html'
  scope:
    num: '=?'
    xsdropdown: '=?'
    unit: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.unit = game.unit scope.unit
    console.log 'buyunit', scope.xsdropdown

    scope.statTwin = scope.unit.stat 'twin', 1
    scope.fullnum = ->
      num = scope.num ? 1
      num = Math.max 1, Math.min scope.unit.maxCostMet(), Math.floor num
      if _.isNaN num
        num = 1
      return num
