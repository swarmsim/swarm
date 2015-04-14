'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:login
 # @description
 # # login
###
angular.module 'swarmApp'
  .directive 'login', (loginApi, $log) ->
    restrict: 'EA'
    template: """
<div>
Login directive! user: {{loginApi.user.username}}
<a ng-if="!loginApi.user.id" href="#/login">Login</a>
<a ng-if="loginApi.user.id" href="javascript:" ng-click="loginApi.logout()">Logout</a>
</div>
"""
    link: (scope, element, attrs) ->
      scope.loginApi = loginApi
