'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:ClearthemeCtrl
 # @description
 # # ClearthemeCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ClearthemeCtrl', ($scope, options, $location) ->
  options.theme $location.search().theme ? 'none'
