'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, game) ->
  $scope.game = game

  $scope.click = (name) ->
    unit = $scope.game.unit name
    console.log 'clicked', name, unit
    console.assert unit
    unit.buy()
