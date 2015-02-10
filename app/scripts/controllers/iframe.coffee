'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:IframeCtrl
 # @description
 # # IframeCtrl
 #
 # Call another swarmsim server via iframe
###
angular.module('swarmApp').controller 'IframeCtrl', ($scope, $log, $routeParams, game, version) ->
  $scope.framed = window.top and window != window.top
  $scope.call = $routeParams.call

  if $scope.call == 'achieve-publictest1'
    # TODO check validity
    response =
      achieved: game.unit('ascension').count().greaterThan(0)
      ascensions: game.unit('ascension').count()
      date: new Date()

  $scope.response = response
  $log.info 'iframe controller:', framed:$scope.framed, call:$scope.call, response:$scope.response
  if $scope.framed
    window.top.postMessage JSON.stringify(response), '*'
