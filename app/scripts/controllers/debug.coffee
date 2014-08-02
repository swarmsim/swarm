'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session) ->
  $scope.session = session
