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

angular.module('swarmApp').factory 'characterApi', ($resource, env) ->
  $resource "#{env.saveServerUrl}/character/:id"

# shortcut
angular.module('swarmApp').factory 'user', (loginApi) ->
  -> loginApi.user

angular.module('swarmApp').config ($httpProvider) ->
  # http://stackoverflow.com/questions/22100084/angularjs-withcredentials-not-sending?rq=1
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true

angular.module('swarmApp').factory 'loginApi', ($http, env, util, $log, session, characterApi) -> new class LoginApi
  constructor: ->
    @user = @whoami().success =>
      # connect legacy character upon page reload
      @maybeConnectLegacyCharacter()

  hasUser: ->
    return @user.id?

  whoami: ->
    $http.get "#{env.saveServerUrl}/whoami"
    .success (data, status, xhr) =>
      @user = data
    .error (data, status, xhr) =>
      @user = {}

  @LOGIN_TAILS =
    kongregate: '/callback'
  login: (strategy, credentials) ->
    tail = @constructor.LOGIN_TAILS[strategy] ? ''
    $http.post "#{env.saveServerUrl}/auth/#{strategy}#{tail}", credentials, {withCredentials: true}
    .success (data, status, xhr) =>
      @user = data.user
      # connect legacy character upon login
      @maybeConnectLegacyCharacter()
 
  logout: ->
    $http.get "#{env.saveServerUrl}/logout", {}, {withCredentials: true}
    .success (data, status, xhr) =>
      @whoami()

  maybeConnectLegacyCharacter: ->
    # TODO: might import from multiple devices. import if there's any chance we'd overwrite the only save!
    # TODO should we freak out if the character's already connected to a different user?
    if @user? and not session.idOnServer?
      $log.debug 'connectLegacyCharacter found a legacy character, connecting...'
      state = session.exportJson()
      character = characterApi.save
        user: @user.id
        name: 'swarm'
        source: 'connectLegacy'
        state: session.exportJson()
        (data, status, xhr) =>
          session.idOnServer = character.id
          session.save()
          $log.debug 'connectLegacyCharacter connected!', session.serverId
        (data, status, xhr) =>
          $log.warn 'connectLegacyCharacter failed!', data, status, xhr
