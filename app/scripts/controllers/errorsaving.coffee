'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:ErrorsavingCtrl
 # @description
 # # ErrorsavingCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ErrorSavingCtrl', ($scope, game, $rootScope) ->
  successCount = failCount = 0

  $scope.game = game
  $scope.form = {}

  $scope.$on 'save', ->
    successCount += 1
  $scope.$on 'save:failed', (e, data) ->
    failCount += 1
    if successCount == 0
      $scope.form.errored = true
      $scope.form.error = data.error?.message
      $scope.form.export = game.session.exportSave()

  # http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = ($event) ->
    $event.target.select()
