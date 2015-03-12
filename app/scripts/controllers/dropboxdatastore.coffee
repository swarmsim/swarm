'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DropboxdatastoreCtrl
 # @description
 # # DropboxdatastoreCtrl
 # Controller of the swarmApp
###

#angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, session, game, env, $log, backfill) ->

angular.module('swarmApp').controller 'DropboxdatastoreCtrl', ($scope, $log, env, dropboxSyncer) ->
  $scope.env = env
  $scope.syncer = dropboxSyncer

  #// Use a pop-up for auth.
  $scope.syncer.dsc.authDriver(new Dropbox.AuthDriver.Popup({receiverUrl: "#{window.location.protocol}//#{window.location.host}#{window.location.pathname}views/dropboxauth.html"}))

  $scope.isAuth = ->
    $scope.syncer.isAuth()

  $scope.updatesavelisting = ->
    $scope.syncer.fetch ->

  $scope.loggedin = ->
    $scope.syncer.init ->

  if $scope.syncer.isAuth()
    # If we're authenticated, update the UI to reflect the logged in status.
    $scope.syncer.init()

  $scope.droplogin = ->
    $log.debug "attempt login"
    $scope.syncer.dsc
      .authenticate( (err,client) ->
        $log.debug "authenticate err: "+err
        $log.debug "authenticate client: "+client
        $scope.syncer.init ->
      )

  $scope.droplogout = ->
    $scope.syncer.savedgames = []
    $scope.syncer._datastore.recordsChanged.removeListener($scope.syncer._recordChangedListener)
    $scope.syncer.dsc.signOut({mustInvalidate: true})

  $scope.fetch = ->
    $scope.syncer.fetch ->

  $scope.addSavegame = ->
    $scope.syncer.push ->

  $scope.importSavegame = ->
    $scope.syncer.pull()

  $scope.clearSavegame = ->
    $scope.syncer.clear ->

  $scope.moment = (datestring=$scope.syncer.savedgame.get 'created') ->
    return moment datestring


angular.module('swarmApp').controller 'KongregateS3Ctrl', ($scope, $log, env, session, kongregate, kongregateS3Syncer, $timeout) ->
  syncer = kongregateS3Syncer
  # http://www.kongregate.com/pages/general-services-api
  $scope.kongregate = kongregate
  $scope.env = env
  if !env.isKongregateSyncEnabled or !kongregate.isKongregate()
    return
  clear = $scope.$watch 'kongregate.kongregate', (newval, oldval) ->
    if newval?
      clear()
      onload()

  $scope.isVisible = syncer.isVisible()
  $scope.isGuest = ->
    return !$scope.api? or $scope.api.isGuest()
  $scope.saveServerUrl = env.saveServerUrl
  $scope.remoteSave = -> syncer.fetched?.encoded
  $scope.remoteDate = -> syncer.fetched?.date
  $scope.policy = -> syncer.policy
  $scope.isPolicyCached = -> syncer.cached
  $scope.policyError = null
  $scope.getAutopushError = -> syncer.getAutopushError()

  onload = ->
    $scope.api = kongregate.kongregate.services
    $scope.api.addEventListener 'login', (event) ->
      $scope.$apply()
    $scope.init()

  $scope.isBrowserSupported = -> window.FormData? and window.Blob?

  cooldown = $scope.cooldown =
    byName: {}
    set: (name, wait=5000) ->
      cooldown.byName[name] = $timeout (-> cooldown.clear name), wait
    clear: (name) ->
      if cooldown.byName[name]
        $timeout.cancel cooldown.byName[name]
        delete cooldown.byName[name]

  $scope.init = (force) ->
    $scope.policyError = null
    cooldown.set 'init'
    q = syncer.init ((data, status, xhr) ->
      $log.debug 'kong syncer inited', data, status
      cooldown.clear 'init'
      return undefined
    ), $scope.api.getUserId(), $scope.api.getGameAuthToken(), force
    #), '21627386', '1dd85395a2291302abdb80e5eeb2ec3a80f594ddaca92fa7606571e5af69e881', force
    q.catch (data, status, xhr) ->
      $scope.policyError = "Failed to fetch sync permissions: #{data?.status}, #{data?.statusText}, #{data?.responseText}"
      cooldown.clear 'init'

  $scope.fetch = ->
    cooldown.set 'fetch'
    xhr = syncer.fetch (data, status, xhr) ->
      $scope.$apply()
      cooldown.clear 'fetch'
      $log.debug 'kong syncer fetched', data, status
      return xhr
    xhr.error (data, status, xhr) ->
      $scope.$apply()
      cooldown.clear 'fetch'
      # 404 is fine. no game saved yet
      if data.status != 404
        $scope.policyError = "Failed to fetch remote saved game: #{data?.status}, #{data?.statusText}, #{data?.responseText}"

  $scope.push = ->
    try
      cooldown.set 'push'
      xhr = syncer.push ->
        cooldown.clear 'push'
        $scope.$apply()
        return xhr
      xhr.error (data, status, xhr) ->
        cooldown.clear 'push'
        $scope.policyError = "Failed to push remote saved game: #{data?.status}, #{data?.statusText}, #{data?.responseText}"
    catch e
      cooldown.clear 'push'
      $log.error "error pushing saved game (didn't even get to the http request!)", e
      $scope.policyError = "Error pushing remote saved game: #{e?.message}"

  $scope.pull = ->
    syncer.pull()

  $scope.clear = ->
    cooldown.set 'clear'
    xhr = syncer.clear (data, status, xhr) ->
      cooldown.clear 'clear'
      $scope.$apply()
      return xhr
    xhr.error (data, status, xhr) ->
      cooldown.clear 'clear'
      $scope.policyError = "Failed to clear remote saved game: #{data?.status}, #{data?.statusText}, #{data?.responseText}"
