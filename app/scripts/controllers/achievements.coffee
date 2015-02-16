'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:AchievementsCtrl
 # @description
 # # AchievementsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'AchievementsCtrl', ($scope, game, $location, $log) ->
  $scope.game = game
  $scope.form =
    show:
      earned: true
      unearned: true
      masked: true

  $scope.state = (achievement) ->
    if achievement.isEarned()
      return 'earned'
    if achievement.isUnmasked()
      return 'unearned'
    # 'masked' zero-point vanity achievements aren't masked, but entirely hidden
    if achievement.type.points <= 0
      return 'hidden'
    return 'masked'
  $scope.isVisible = (achievement) ->
    state = $scope.state achievement
    if state == 'earned'
      return $scope.form.show.earned
    else if state == 'unearned'
      return $scope.form.show.unearned
    else
      return $scope.form.show.masked
  
  $scope.achieveclick = (achievement) ->
    $log.debug 'achieveclick', achievement
    $scope.$emit 'achieveclick', achievement
