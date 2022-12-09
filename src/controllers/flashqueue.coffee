'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:FlashqueueCtrl
 # @description
 # # FlashqueueCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'FlashQueueCtrl', ($scope, flashqueue) ->
  $scope.achieveQueue = flashqueue
