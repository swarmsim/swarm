'use strict'

angular.module('swarmApp').config ($httpProvider) ->
  # http://stackoverflow.com/questions/22100084/angularjs-withcredentials-not-sending?rq=1
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true

###*
 # @ngdoc function
 # @name swarmApp.controller:LoginCtrl
 # @description
 # # LoginCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'LoginCtrl', ($scope, env, $sce, $http) ->
  #$scope.env = env
  $scope.action = $sce.trustAsResourceUrl "#{env.saveServerUrl}/auth/local"
  $scope.form = {redirect:document.location.href}
  $scope.submit = ->
    $http.post "#{env.saveServerUrl}/auth/local", $scope.form, {withCredentials: true}
    .success (data, status, xhr) ->
      console.log 'login post success', data, status, xhr
    .error (data, status, xhr) ->
      console.log 'login post error', data, status, xhr
