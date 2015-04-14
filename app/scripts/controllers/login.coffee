'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:LoginCtrl
 # @description
 # # LoginCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'LoginCtrl', ($scope, loginApi) ->
  $scope.form = {}
  $scope.submit = ->
    loginApi.login 'local', $scope.form
