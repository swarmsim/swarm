'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module 'swarmApp'
  .directive 'playfab', ->
    #templateUrl: 'views/playfab/signin.html'
    #templateUrl: 'views/playfab/options.html'
    #templateUrl: 'views/playfab/signup.html'
    template: """
<div ng-include="'views/playfab/title.html'"></div>
<ul class="nav nav-tabs">
  <li role="presentation" ng-class="{active:active==='signup'}"><a href="javascript:" ng-click="setActive('signup')">Sign up</a></li>
  <li role="presentation" ng-class="{active:active==='login'}"><a href="javascript:" ng-click="setActive('login')">Log in</a></li>
  <li role="presentation" ng-class="{active:active==='forgot'}"><a href="javascript:" ng-click="setActive('forgot')">Forgot password</a></li>
</ul>
<div ng-show="active==='signup'" ng-include="'views/playfab/signup.html'"></div>
<div ng-show="active==='login'" ng-include="'views/playfab/login.html'"></div>
<div ng-show="active==='forgot'" ng-include="'views/playfab/forgot.html'"></div>

<div ng-if="false" ng-include="'views/playfab/options.html'"></div>
"""
    restrict: 'EA'
    link: (scope, element, attrs) ->
      scope.active = 'signup'
      scope.setActive = (active) ->
        scope.active = active
        return false
      scope.form = {}

      scope.runSignup = () ->
        console.log('signup')
      scope.runLogin = () ->
        console.log('login')
      scope.runForgot = () ->
        console.log('forgot')
