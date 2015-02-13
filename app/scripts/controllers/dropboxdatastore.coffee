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

    $scope.app_key = '6hagxaf8041upxz';
    $scope.dsc =  new Dropbox.Client({key: $scope.app_key });
#	// Use a pop-up for auth.
    #$scope.dsc.authDriver(new Dropbox.AuthDriver.Popup({ receiverUrl: window.location.href + 'oauth_receiver.html' }));
    $scope.dsc.authDriver(new Dropbox.AuthDriver.Popup({ receiverUrl: window.location.protocol + '//' + window.location.host + '/views/dropboxauth.html'  }));

    #else
			#// If we're authenticated, update the UI to reflect the logged in status.
		#} else {
			#// Otherwise show the login button.
			#$('#login').show();
		#}


    $scope.isAuth = ->
        return $scope.dsc.isAuthenticated();


    $scope.updatesavelisting = (event) ->
       #records = event.affectedRecordsForTable('swarmstate');
       taskTable = _datastore.getTable('saveddata');
       $scope.savedgames = taskTable.query();


    $scope.loggedin = () ->
      $log.debug "loggedIn()";
      $('#dropboxlogin').hide();

      datastoreManager = new Dropbox.Datastore.DatastoreManager($scope.dsc);
      datastoreManager.openDefaultDatastore( (err,datastore)->
          $log.debug "opendef err: "+err if err;
          $log.debug "opendef datastore: "+datastore;

          _datastore = datastore;
          datastore.recordsChanged.addListener( $scope.updatesavelisting );
          $scope.updatesavelisting();
         
      );
      $('#dropboxlogout').show();
   
    # First check if we're already authenticated.
    $scope.dsc.authenticate({ interactive : false});


    if $scope.dsc.isAuthenticated()
      # If we're authenticated, update the UI to reflect the logged in status.
      $scope.loggedin()
    else
      # Otherwise show the login button.
      $('#dropboxlogin').show();


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
        $('#dropboxlogin').show();
        $('#dropboxlogout').hide();
    
    $scope.addSavegame =  ->
        $log.debug 'saving to dropbox'
        taskTable = _datastore.getTable('saveddata')

        firstTask = taskTable.insert({
                        name: $scope.newSavegame,
                        created: new Date()
                        ,data: session.exportSave()
                    });
        $scope.newSavegame = ''; 

    $scope.importSavegame = (savegame)  ->
        $log.debug 'do import of:'+ savegame;
        $scope.importSave(savegame.get('data'));

    
    $scope.deleteSavegame = (savegame)  ->
        $log.debug 'do delete of:'+ savegame;
        _datastore.getTable('swarmstate').get(savegame.getId()).deleteRecord();
