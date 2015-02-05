'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DropboxdatastoreCtrl
 # @description
 # # DropboxdatastoreCtrl
 # Controller of the swarmApp
###

#angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, session, game, env, $log, backfill) ->

angular.module('swarmApp').controller 'DropboxdatastoreCtrl', ($scope, $log , dropboxdatastore, env , dropstoreClient, session) ->

    #$scope.dropstore = dropstoreClient
    _datastore = null
    $scope.env = env


    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
    $log.debug 'hello world:' ;

    $scope.app_key = 'k614nfbt1fp1mj7';
    $scope.oauth_token = 'ajamBZAOqM4AAAAAAAABsOkiHt2xjk1hOjloitZmn_dx9s6wS1plhTzICsTBLFHq';

    $scope.savedgames = [];
    $scope.newSavegame = ''; 


    $scope.isAuth = ->
        return dropstorec.isAuthenticated();

    $scope.doAuth = -> 
      $log.debug "do auth";
      #dropstoreClient.create({key: $scope.app_key })
      dropstoreClient.create({key: $scope.app_key , token: $scope.oauth_token })
        .authenticate({interactive: false })
        .then((datastoreManager) -> 
            console.log('completed authentication');
            return datastoreManager.openDefaultDatastore();
        )
        .then((datastore) ->
           console.log('completed openDefaultDatastore');
           _datastore = datastore


           _datastore.SubscribeRecordsChanged((event) ->
               records = event.affectedRecordsForTable('swarmstate');
               taskTable = _datastore.getTable('swarmstate');
               $scope.savedgames = taskTable.query();
           );

           taskTable = _datastore.getTable('swarmstate');
           $scope.savedgames = taskTable.query();
        );
    
    $scope.addSavegame =  ->
        taskTable = _datastore.getTable('swarmstate')

        firstTask = taskTable.insert({
                        state: $scope.newSavegame,
                        completed: false,
                        created: new Date()
                        ,export: session.exportSave()
                    });
        $scope.newSavegame = ''; 


    
    $scope.deleteSavegame = (savegame)  ->
        $log.debug 'do delete of:'+ savegame;
        _datastore.getTable('swarmstate').get(savegame.getId()).deleteRecord();
