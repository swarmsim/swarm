'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:AchievementsCtrl
 # @description
 # # AchievementsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'AchievementsCtrl', ($scope, game) ->
  $scope.game = game
  $scope.form =
    show:
      earned: true
      unearned: true

  $scope.isVisible = (achievement) ->
    if achievement.isEarned()
      return $scope.form.show.earned
    else
      return $scope.form.show.unearned
