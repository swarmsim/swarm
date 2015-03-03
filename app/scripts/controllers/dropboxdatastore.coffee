'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DropboxdatastoreCtrl
 # @description
 # # DropboxdatastoreCtrl
 # Controller of the swarmApp
###

#angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, session, game, env, $log, backfill) ->

angular.module('swarmApp').controller 'DropboxdatastoreCtrl', ($scope, $log ,  env , session) ->

    #$scope.dropstore = dropstoreClient
    _datastore = null
    _recschanged = null
    $scope.env = env


    $scope.savedgames = [];
    $scope.newSavegame = ''; 

    $scope.app_key = env.dropboxAppKey
    $log.debug 'env.dropboxAppKey:', env.dropboxAppKey
    $scope.dsc =  new Dropbox.Client({key: $scope.app_key });
#	// Use a pop-up for auth.
    #$scope.dsc.authDriver(new Dropbox.AuthDriver.Popup({ receiverUrl: window.location.href + 'oauth_receiver.html' }));
    $scope.dsc.authDriver(new Dropbox.AuthDriver.Popup({ receiverUrl: "#{window.location.protocol}//#{window.location.host}#{window.location.pathname}views/dropboxauth.html"  }))

    #else
			#// If we're authenticated, update the UI to reflect the logged in status.
		#} else {
			#// Otherwise show the login button.
			#$('#login').show();
		#}


    $scope.isAuth = ->
        return $scope.dsc.isAuthenticated()

    getTable = ->
      return _datastore.getTable 'saveddata'

    newSavegame = 'game'
    $scope.updatesavelisting = (event) ->
       #records = event.affectedRecordsForTable('swarmstate');
       taskTable = getTable()
       $scope.savedgames = taskTable.query name:newSavegame
       $scope.savedgame = $scope.savedgames[0]

    $scope.loggedin = () ->
      $log.debug "loggedIn()";

      datastoreManager = new Dropbox.Datastore.DatastoreManager($scope.dsc);
      datastoreManager.openDefaultDatastore (err,datastore)->
          $log.debug "opendef err: "+err if err;
          $log.debug "opendef datastore: "+datastore;

          _datastore = datastore;
          datastore.recordsChanged.addListener( $scope.updatesavelisting );
          $scope.updatesavelisting();
   
    # First check if we're already authenticated.
    $scope.dsc.authenticate({ interactive : false});


    if $scope.dsc.isAuthenticated()
      # If we're authenticated, update the UI to reflect the logged in status.
      $scope.loggedin()


    $scope.droplogin = -> 
      $log.debug "attempt login";
      $scope.dsc
        .authenticate( (err,client)->
          $log.debug "authenticate err: "+err;
          $log.debug "authenticate client: "+client;
          $scope.loggedin()
         
        );
       

    $scope.droplogout = -> 
        $scope.savedgames = [];
        _datastore.recordsChanged.removeListener($scope.updatesavelisting) ;
        $scope.dsc.signOut({mustInvalidate: true});
    
    $scope.addSavegame = ->
        for save in $scope.savedgames
          $scope.deleteSavegame save
        $log.debug 'saving to dropbox'
        taskTable = getTable()

        firstTask = taskTable.insert
          name: newSavegame
          created: new Date()
          data: session.exportSave()
        $scope.updatesavelisting()

    $scope.importSavegame = (savegame=$scope.savedgame)  ->
        $log.debug 'do import of:'+ savegame;
        $scope.importSave(savegame.get('data'));
    
    $scope.deleteSavegame = (savegame=$scope.savedgame)  ->
        $log.debug 'do delete of:'+ savegame;
        getTable().get(savegame.getId()).deleteRecord()

    $scope.moment = (datestring=savedgame.get 'created') ->
      return moment datestring


angular.module('swarmApp').controller 'KongregateS3Ctrl', ($scope, $log, env, session, kongregate, kongregateS3Syncer, $timeout) ->
  syncer = kongregateS3Syncer
  # http://www.kongregate.com/pages/general-services-api
  $scope.kongregate = kongregate
  if !kongregate.isKongregate()
    return
  clear = $scope.$watch 'kongregate.kongregate', (newval, oldval) ->
    if newval?
      clear()
      onload()

  $scope.isGuest = ->
    return !$scope.api? or $scope.api.isGuest()
  $scope.saveServerUrl = env.saveServerUrl
  $scope.remoteSave = -> syncer.fetched?.encoded
  $scope.remoteDate = -> syncer.fetched?.date
  $scope.policy = -> syncer.policy
  $scope.isPolicyCached = -> syncer.cached
  $scope.policyError = null

  onload = ->
    $scope.api = kongregate.kongregate.services
    $scope.api.addEventListener 'login', (event) ->
      $scope.$apply()

    $scope.init()

  cooldown = $scope.cooldown =
    byName: {}
    set: (name, wait=5000) ->
      cooldown.byName[name] = $timeout (->cooldown.clear name), wait
    clear: (name) ->
      if cooldown.byName[name]
        $timeout.cancel cooldown.byName[name]
        delete cooldown.byName[name]

  $scope.init = (force) ->
    $scope.policyError = null
    cooldown.set 'init'
    xhr = syncer.init ((data, status, xhr) ->
      $log.debug 'kong syncer inited', data, status
      cooldown.clear 'init'
      $scope.fetch()
      return undefined
    ), $scope.api.getUserId(), $scope.api.getGameAuthToken(), force
    #), '21627386', '1dd85395a2291302abdb80e5eeb2ec3a80f594ddaca92fa7606571e5af69e881', force
    xhr?.error (data, status, xhr) ->
      $scope.policyError = "Failed to fetch sync permissions: #{data?.status}, #{data?.statusText}, #{data?.responseText}"
      cooldown.clear 'init'
      $scope.$apply()
      
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
      # 404 is fine; no game saved yet
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
