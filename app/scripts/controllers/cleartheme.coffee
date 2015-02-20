'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:ClearthemeCtrl
 # @description
 # # ClearthemeCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ClearthemeCtrl', ($scope, options) ->
  options.theme 'none'
