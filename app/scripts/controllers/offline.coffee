'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:OfflineCtrl
 # @description
 # # OfflineCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'OfflineCtrl', ($scope, game) ->
  $scope.achieved = game.unit('ascension').count().greaterThan(0)
  $scope.feedbackUrl = ->
    game.session.feedbackUrl()
