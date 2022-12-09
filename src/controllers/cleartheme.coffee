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
    theme = $location.search().theme
    # if we're setting themeExtra without a theme, don't change the theme
    if not $location.search().themeExtra
      theme = 'none'
    if theme
      options.theme theme
  if $location.search().themeExtra
    options.themeExtra $location.search().themeExtra ? ''
