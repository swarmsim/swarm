'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:login
 # @description
 # # login
###
angular.module 'swarmApp'
  .directive 'login', (userApi, $http, env, $log) ->
    restrict: 'EA'
    template: """
<div>
Login directive! user: {{user.username}}
<a ng-if="!user.id" href="#/login">Login</a>
<a ng-if="user.id" href="javascript:" ng-click="logout()">Logout</a>
</div>
"""
    link: (scope, element, attrs) ->
      scope.user = userApi.whoami ->
        console.log 'user loaded', scope.user, scope.user.username
      #scope.user = userApi.get id:2
      scope.logout = ->
        $http.get "#{env.saveServerUrl}/logout", {}, {withCredentials: true}
        .success (data, status, xhr) ->
          scope.user = userApi.whoami ->
            if scope.user.id
              console.log 'logout reported success, but /whoami still has a user?', scope.user
        .error (data, status, xhr) ->
          $log.error 'logout error', data, status, xhr
