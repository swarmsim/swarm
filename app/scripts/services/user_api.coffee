'use strict'

###*
 # @ngdoc service
 # @name swarmApp.userApi
 # @description
 # # userApi
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'userApi', ($resource, env) ->
  $resource "#{env.saveServerUrl}/user/:id"

# shortcut
angular.module('swarmApp').factory 'user', (loginApi) ->
  -> loginApi.user

angular.module('swarmApp').config ($httpProvider) ->
  # http://stackoverflow.com/questions/22100084/angularjs-withcredentials-not-sending?rq=1
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true

angular.module('swarmApp').factory 'loginApi', ($http, env, util, $log) -> new class LoginApi
  constructor: ->
    @user = @whoami()

  hasUser: ->
    return @user.id?

  whoami: ->
    $http.get "#{env.saveServerUrl}/whoami"
    .success (data, status, xhr) =>
      @user = data

  @LOGIN_TAILS =
    kongregate: '/callback'
  login: (strategy, credentials) ->
    tail = @constructor.LOGIN_TAILS[strategy] ? ''
    $http.post "#{env.saveServerUrl}/auth/#{strategy}#{tail}", credentials, {withCredentials: true}
    .success (data, status, xhr) =>
      @user = data.user
 
  logout: ->
    $http.get "#{env.saveServerUrl}/logout", {}, {withCredentials: true}
    .success (data, status, xhr) =>
      @whoami()
