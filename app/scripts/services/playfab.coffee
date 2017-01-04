'use strict'

# https://github.com/PlayFab/JavaScriptSDK

###*
 # @ngdoc service
 # @name swarmApp.playfab
 # @description
 # # playfab
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Playfab', ($q) -> class Playfab
  constructor: ->
  isAuthed: -> !!@auth
  logout: -> @auth = null

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
          @auth =
            raw: response.data
            rawType: 'login'
            email: email
          @_loadUserData(response.data.InfoResultPayload.UserData)
          resolve(response.data)
        else
          reject(error)

  # TODO: make this work; support guest logins?
  autologin: (customId) -> $q (resolve, reject) =>
    PlayFabClientSDK.LoginWithCustomId
      CustomId: customId
      InfoRequestParameters:
        GetUserAccountInfo: true
        GetUserData: true
      (response, error) =>
        if response && response.code == 200
          console.log('autologin success', response)
          @auth =
            raw: response.data
            rawType: 'autologin'
            email: email
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
      Data:
        state: state
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
      KeysToRemove: ['state']
      (response, error) =>
        if response && response.code == 200
          console.log('clear success', response)
          @auth.state = null
          @auth.lastUpdated = new Date().getTime()
          resolve(@auth)
        else
          reject(error)

  _loadUserData: (data) ->
    @auth.state = data.state?.Value
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
