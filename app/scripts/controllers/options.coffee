'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:OptionsCtrl
 # @description
 # # OptionsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, session, game, env, $log) ->
  $scope.options = options
  $scope.game = game
  $scope.session = session
  $scope.env = env
  $scope.imported = {}

  # http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = ($event) ->
    $event.target.select()

  $scope.importSave = (encoded) ->
    $scope.imported = {}
    try
      $scope.game.importSave encoded
      $scope.imported.success = true
      $scope.$emit 'import', {success:true}
      $log.debug 'import success'
    catch e
      $scope.imported.error = true
      $scope.$emit 'import', {success:false}
      $log.warn 'import error', e

  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. No reset-bonuses here. You sure?'
      $scope.game.reset()
      $location.url '/'
