'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugapiCtrl
 # @description
 # # DebugapiCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugApiCtrl', ($scope, env, loginApi, $http, $log) ->
  $scope.env = env
  $scope.loginApi = loginApi
  $scope.form = {url:'/whoami'}

  $scope.calling = false
  appendResult = (text) ->
    $('<pre>').text(text).prependTo '#testApiCallResults'
  submitApiCall = window.submitApiCall = (request) ->
    if $scope.calling
      appendResult 'already calling an api. please be patient.'
      return $log.error 'already calling an api. please be patient.'
    $log.info 'debugapi request', request
    $scope.calling = new Date()
    $http request
    .success (data, status, xhr) ->
      dur = new Date().getTime() - $scope.calling.getTime()
      $scope.calling = false
      $log.info 'debugapi response', data, status, xhr
      appendResult "success: #{status}, #{dur}ms\n\n#{JSON.stringify data, null, 2}"
    .error (data, status, xhr) ->
      dur = new Date().getTime() - $scope.calling.getTime()
      $scope.calling = false
      $log.warn 'debugapi error', data, status, xhr
      appendResult "ERROR: #{status}, #{dur}ms\n\n#{JSON.stringify data, null, 2}"

  $scope.submitApiCall = (method) ->
    submitApiCall
      method: method
      url: "#{env.saveServerUrl}#{$scope.form.url}"
      headers: $scope.form.headers
      data: $scope.form.data
