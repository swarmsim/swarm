'use strict'

###*
 # @ngdoc service
 # @name swarmApp.Dropboxdatastore
 # @description
 # # Dropboxdatastore
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Dropboxdatastore', ($log, util) -> class Dropboxdatastore
  constructor: (@session) ->
    $log.debug 'datastore constructed' + oath_token + "...."

#angular.module('swarmApp') .service 'Dropboxdatastore', ->
    # AngularJS will instantiate a singleton by calling "new" on this function

  isAuthenticated: ->
    return true;

  oath_token = 'this is my oathtoekn';


angular.module('swarmApp').factory 'dropboxdatastore', (Dropboxdatastore, session) ->
  return new Dropboxdatastore session
