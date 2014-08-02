'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, session) ->
  $scope.session = session

  $scope.click =
    food: ->
      $scope.session.food += 1
    drone: ->
      cost = 10
      if $scope.session.food >= cost
        $scope.session.food -= cost
        $scope.session.drone += 1
