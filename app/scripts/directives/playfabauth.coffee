'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'playfabauth', (playfab) ->
  templateUrl: 'views/playfab/auth.html'
  restrict: 'EA'
  link: (scope, element, attrs) ->
    scope.setActive = (active) ->
      scope.forgotSuccess = null
      scope.error = null
      scope.active = active
      return false
    scope.setActive 'login'
    #scope.form = {}
    scope.form = {email: 'test@erosson.org', password: 'testtest', password2: 'testtest'}
    handleError = (error) ->
      scope.error =
        main: error?.errorMessage
        email: error?.errorDetails?.Email?[0]
        password: error?.errorDetails?.Password?[0]
      console.log 'fail', error, scope.error

    scope.runSignup = () ->
      scope.error = null
      playfab.signup(scope.form.email, scope.form.password).then(
        (data) ->
          console.log 'success', data
        handleError)
    scope.runLogin = () ->
      scope.error = null
      playfab.login(scope.form.email, scope.form.password).then(
        (data) ->
          console.log 'success', data
        handleError)
    scope.runForgot = () ->
      scope.forgotSuccess = null
      scope.error = null
      playfab.forgot(scope.form.email).then(
        (data) ->
          console.log 'success', data
          scope.forgotSuccess = true
        handleError)
