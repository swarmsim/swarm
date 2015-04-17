'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:login
 # @description
 # # login
###
angular.module 'swarmApp'
  .directive 'login', (loginApi, $log, kongregate, env) ->
    restrict: 'EA'
    template: """
<div ng-cloak ng-if="env.isServerFrontendReleased">
  Login directive! user: {{loginApi.user.username}}
  <div ng-if="!loginApi.user.id">
    <a ng-if="isKongregate()" href="javascript:" ng-click="kongregateLogin()">Login</a>
    <a ng-if="!isKongregate()" href="#/login">Login</a>
  </div>
  <a ng-if="loginApi.user.id && !isKongregate()" href="javascript:" ng-click="loginApi.logout()">Logout</a>
</div>
"""
    link: (scope, element, attrs) ->
      scope.env = env
      scope.loginApi = loginApi
      scope.isKongregate = -> kongregate.isKongregate()
      scope.kongregateLogin = ->
        kongregate.kongregate.services.showRegistrationBox()
