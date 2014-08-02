'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp')
  .controller 'AboutCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
