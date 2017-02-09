'use strict'

# https://github.com/PlayFab/JavaScriptSDK

angular.module('swarmApp').factory 'playfabCredentialStore', ($log) -> new class PlayfabCredentialStore
  constructor: (@key="playfabCredentials") ->
  write: (email, password) ->
    # Storing a password this way is terribly insecure.
    # But... playfab doesn't have its own remember-me option, the
    # convenience is more important than the security for my little game,
    # other games/sites do this, and I can't be bothered to set up
    # something with playfab customids right now.
    window.localStorage.setItem @key, JSON.stringify
      email: email
      #password: password
      # This is still insecure, but if I'm going to take shortcuts here,
      # the least we can do is obfuscate it slightly
      password: window.btoa password
  read: ->
    ret = window.localStorage.getItem @key
    if ret
      try
        ret = JSON.parse ret
        ret.password = window.atob ret.password
        return ret
      catch e
        $log.warning e
        return undefined
  clear: ->
    window.localStorage.removeItem @key

# https://developer.playfab.com/en-us/F810/limits
# Playfab has a size limit of 10k bytes per key. Swarmsim's passed that before. We can update 10 keys per push for a limit of 100k, which is enough.
angular.module('swarmApp').factory 'playfabStateChunker', -> window.persist.chunker

###*
 # @ngdoc service
 # @name swarmApp.playfab
 # @description
 # # playfab
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Playfab', ($q, $log, playfabCredentialStore, playfabStateChunker) -> class Playfab
  constructor: ->
  isAuthed: -> !!@auth
  logout: ->
    @auth = null
    playfabCredentialStore.clear()

  login: (email, password, remember) -> $q (resolve, reject) =>
    PlayFabClientSDK.LoginWithEmailAddress
      Email: email
      Password: password
      InfoRequestParameters:
        GetUserAccountInfo: true
        GetUserData: true
      (response, error) =>
        if response && response.code == 200
          console.log('login success', response)
          if remember
            playfabCredentialStore.write(email, password)
          @auth =
            raw: response.data
            rawType: 'login'
            email: email
          @_loadUserData(response.data.InfoResultPayload.UserData)
          resolve(response.data)
        else
          reject(error)

  autologin: ->
    creds = playfabCredentialStore.read()
    if creds?.email && creds?.password
      $log.debug 'found playfab autologin creds'
      return @login creds.email, creds.password, false
    else
      $log.debug 'playfab autologin failed, no creds stored'
      return $q (resolve, reject) -> reject()

  # https://api.playfab.com/Documentation/Client/method/LoginWithKongregate
  kongregateLogin: (userId, authToken) -> $q (resolve, reject) =>
    PlayFabClientSDK.LoginWithKongregate
      KongregateId: userId
      AuthTicket: authToken
      CreateAccount: true
      InfoRequestParameters:
        GetUserAccountInfo: true
        GetUserData: true
      (response, error) =>
        if response && response.code == 200
          console.log('login success', response)
          @auth =
            raw: response.data
            rawType: 'login'
          @_loadUserData(response.data.InfoResultPayload.UserData)
          resolve(response.data)
        else
          reject(error)

  signup: (email, password) -> $q (resolve, reject) =>
    PlayFabClientSDK.RegisterPlayFabUser
      RequireBothUsernameAndEmail: false # email's enough, no need for usernames
      Email: email
      Password: password
      (response, error) =>
        if response && response.code == 200
          console.log('signup success', response)
          @auth =
            raw: response.data
            rawType: 'signup'
            email: email
            state: null
            lastUpdated: new Date().getTime()
          resolve(response.data)
        else
          reject(error)

  forgot: (email) -> $q (resolve, reject) =>
    PlayFabClientSDK.SendAccountRecoveryEmail
      TitleId: window.PlayFab.settings.titleId
      Email: email
      (response, error) =>
        if response && response.code == 200
          console.log('forgot success', response)
          resolve(response.data)
        else
          reject(error)

  push: (state) -> $q (resolve, reject) =>
    # limit is 10000 bytes per key. We can chunk it into 10 keys per request though.
    # TODO: chunking.
    # https://developer.playfab.com/en-us/F810/limits
    PlayFabClientSDK.UpdateUserData
      Data: playfabStateChunker.encode(state)
      (response, error) =>
        if response && response.code == 200
          console.log('push success', response)
          @auth.state = state
          @auth.lastUpdated = new Date().getTime()
          resolve(@auth)
        else
          reject(error)

  clear: -> $q (resolve, reject) =>
    PlayFabClientSDK.UpdateUserData
      KeysToRemove: playfabStateChunker.keys()
      (response, error) =>
        if response && response.code == 200
          console.log('clear success', response)
          @auth.state = null
          @auth.lastUpdated = new Date().getTime()
          resolve(@auth)
        else
          reject(error)

  _loadUserData: (data) ->
    @auth.state = playfabStateChunker.decode(data)
    @auth.lastUpdated = new Date(data.state?.LastUpdated).getTime()
  fetch: -> $q (resolve, reject) =>
    PlayFabClientSDK.GetUserData {},
      (response, error) =>
        if response && response.code == 200
          console.log('fetch success', response)
          @_loadUserData(response.data.Data)
          resolve(@auth)
        else
          reject(error)

angular.module('swarmApp').factory 'playfab', (Playfab, env) ->
  window.PlayFab.settings.titleId = env.playfabTitleId
  return new Playfab()
