'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'playfabauth', ->
  templateUrl: 'views/playfab/auth.html'
  restrict: 'EA'
  link: (scope, element, attrs) ->
    console.log('playfab auth')
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
