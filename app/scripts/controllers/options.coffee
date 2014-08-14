'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:OptionsCtrl
 # @description
 # # OptionsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, game) ->
  $scope.options = options
  $scope.game = game

  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. No reset-bonuses here. You sure?'
      $scope.game.reset()
      $location.url '/'
