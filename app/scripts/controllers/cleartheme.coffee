'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:ClearthemeCtrl
 # @description
 # # ClearthemeCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ClearthemeCtrl', ($scope, options, $location) ->
  if $location.search().custom and $location.search().theme
    options.customTheme $location.search().theme
  else
    options.theme $location.search().theme ? 'none'
  if $location.search().themeExtra
    options.theme $location.search().themeExtra ? ''
