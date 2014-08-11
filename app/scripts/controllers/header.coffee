'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, env) ->
  $scope.env = env
  
  $scope.isNonprod = ->
    $scope.env and $scope.env != 'prod'
