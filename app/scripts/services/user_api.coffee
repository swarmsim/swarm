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

angular.module('swarmApp').factory 'commandApi', ($resource, env) ->
  $resource "#{env.saveServerUrl}/command/:id"

# shortcut
angular.module('swarmApp').factory 'user', (loginApi) ->
  -> loginApi.user

angular.module('swarmApp').config ($httpProvider) ->
  # http://stackoverflow.com/questions/22100084/angularjs-withcredentials-not-sending?rq=1
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true

angular.module('swarmApp').factory 'loginApi', (loginApiEnabled, env) ->
  if env.isServerBackendEnabled
    return loginApiEnabled
  ret = {}
  for method, fn of loginApiEnabled
    ret[method] = ->
      throw new Error 'login backend is disabled'
  return ret

angular.module('swarmApp').factory 'loginApiEnabled', ($http, env, util, $log, session, characterApi, isKongregate, commandApi) -> new class LoginApi
  constructor: ->
    @characters = {}
    if env.isServerBackendEnabled
      @userLoading = @whoami()
      .success =>
        # connect legacy character upon page reload
        @maybeConnectLegacyCharacter()
        #if env.isServerFrontendEnabled
        #  # TODO import most recently used character from server. need to know when connectLegacyCharacter above is done, though
        $log.debug 'user already logged in', @user
      .error =>
        # not logged in.
        # TODO guest login, with some caveats:
        # * no guest login if isKongregate(), kong might still be loading
        #   * kong has guest users too, though! what if their guest isn't logged in?
        # * yes guest login if there's a saved character, which proves this isn't a new visitor - it's a legacy character.
        #   * import the legacy character right away, and don't create a new character for the guest.
        # * no guest login YET if there's no saved character - this is a fresh visitor, and they might already have an account they're about to log in to.
        #   * guest login comes later, once they take an action like buying a drone.
        #     * how to handle creating their character, though? new characters shouldn't start as legacy imports, and we can't just allow infinitely backdated character creation!
        # OR, maybe just guest-login now in every case, and delete the guest later if it's not needed? creating an empty user/character in the db isn't very expensive. pollutes the db though. eh... do it anyway.
        if not isKongregate()
          @login 'guestuser'
          .success =>
            $log.debug 'created guest user'
            @maybeConnectLegacyCharacter()
          .error =>
            $log.debug 'failed to create guest user'
  hasUser: ->
    return @user.id?

  whoami: ->
    @user = {}
    $http.get "#{env.saveServerUrl}/whoami"
    .success (data, status, xhr) =>
      _.extend @user, data
    .error (data, status, xhr) =>
      $log.warn 'whoami failed'

  @LOGIN_TAILS =
    kongregate: '/callback'
    guestuser: '/callback'
  login: (strategy, credentials={}) ->
    tail = @constructor.LOGIN_TAILS[strategy] ? ''
    if not env.saveServerUrl
      $log.error "env.saveServerUrl is blank, expect all swarmapi calls to fail. I hope this isn't the production environment!"
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
    if @user? and not session.state.idOnServer? and not env.isServerFrontendEnabled
      $log.debug 'connectLegacyCharacter found a legacy character, connecting...'
      state = session.exportJson()
      character = characterApi.save
        user: @user.id
        name: 'swarm'
        source: 'connectLegacy'
        state: session.exportJson()
        (data, status, xhr) =>
          session.state.idOnServer = character.id
          @characters[character.id] = character
          # We're now avoiding session.save in favor of commands in most places, but this one's purely local and odesn't need to be saved to the server - it's from the server
          session.save()
          $log.debug 'connectLegacyCharacter connected!', session.state.serverId
        (data, status, xhr) =>
          $log.warn 'connectLegacyCharacter failed!', data, status, xhr

  saveCommand: (commandBody) ->
    # Just save the character for now. Later we'll save the command, but just get the traffic flowing to the server to see if we'll scale.
    id = session.character?.id ? session.state.idOnServer
    if not id?
      $log.debug 'server saveCommand quitting because character has no id. trying connectlegacycharacter.', commandBody
      return @maybeConnectLegacyCharacter()
      # TODO save the first command; focus on server character more
    state = session.exportJson()
    commandBody = _.omit commandBody, ['unit', 'upgrade', 'achievement']
    $log.debug 'server saveCommand start', command
    command = commandApi.save
      character: session.state.idOnServer
      body: commandBody
      state: state
      (data, status, xhr) =>
        $log.debug 'server saveCommand success', command
      (data, status, xhr) =>
        $log.warn 'server saveCommand failed!', data, status, xhr
        # TODO remove this when truly depending on server characters! this is v1.1 test code.
        if 400 <= data.status < 500
          $log.warn 'server saveCommand bad request. trying to recreate character on server.', command
          delete session.state.idOnServer
          @maybeConnectLegacyCharacter()
