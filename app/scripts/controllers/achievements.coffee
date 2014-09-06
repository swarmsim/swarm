'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:AchievementsCtrl
 # @description
 # # AchievementsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'AchievementsCtrl', ($scope, game, env, $location, $log) ->
  if not env.achievementsEnabled
    $location.url '/'
  $scope.game = game
  $scope.form =
    show:
      earned: true
      unearned: true

  $scope.isVisible = (achievement) ->
    if achievement.isEarned()
      return $scope.form.show.earned
    else
      return $scope.form.show.unearned && achievement.type.unearnedvisibility != 'hidden'
  
  $scope.achieveclick = (achievement) ->
    $log.debug 'achieveclick', achievement
    $scope.$emit 'achieveclick', achievement
