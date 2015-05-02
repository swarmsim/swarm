'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:LoginCtrl
 # @description
 # # LoginCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'LoginCtrl', ($scope, env, loginApi, $log, $interval) ->
  $scope.form = {}
  $scope.user = -> loginApi.user
  $scope.apiUrl = env.saveServerUrl
  $scope.loginPopup = (provider) ->
    loginwin = window.open "#{$scope.apiUrl}/auth/#{provider}/", provider, {height:200, width:200}
    # poll for window-close.
    promise = $interval =>
      $log.debug 'polling for login window close...'
      if loginwin.closed
        $log.debug 'login window closed'
        loginApi.whoami()
        $interval.cancel promise
    , 400
  $scope.submit = ->
    loginApi.login 'local', $scope.form
