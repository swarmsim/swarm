'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UserCtrl
 # @description
 # # UserCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UserCtrl', ($scope, $routeParams, $log, userApi, loginApi, $location) ->
  $log.debug 'userctrl', $routeParams
  if not (userId=$routeParams.user)?
    $location.url '/'
  # special case: /user/me gets the current user
  if userId == 'me'
    $scope.user = loginApi.user
    $log.debug 'userload hook', $scope.user
    loginApi.userLoading.success =>
      $log.debug 'user loaded', $scope.user
    $scope.isSelf = true
  else
    $scope.user = userApi.get id:userId
