'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:AchievementsCtrl
 # @description
 # # AchievementsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'AchievementsCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
