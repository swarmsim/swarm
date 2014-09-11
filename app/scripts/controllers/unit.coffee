'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UnitCtrl
 # @description
 # # UnitCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UnitCtrl', ($scope, $log, $routeParams, $location, game, commands) ->
  $scope.game = game
  $scope.commands = commands
  $scope.cur = $scope.game.unitByLabel $routeParams.unit
  if (not $scope.cur?) or (not $scope.cur.isVisible())
    $location.url '/'
  $log.debug $scope.cur

  $scope.swipe = (unit) ->
    if unit and unit.isVisible()
      $location.url "/unit/#{unit.unittype.label}"
