'use strict'

###*
 # @ngdoc service
 # @name swarmApp.userApi
 # @description
 # # userApi
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'userApi', ($resource, env, util) ->
  util.assert env.saveServerUrl, 'env.saveserverurl required'
  return $resource "#{env.saveServerUrl}/user/:id", null,
    whoami: {method: 'GET', url: "#{env.saveServerUrl}/whoami"}
