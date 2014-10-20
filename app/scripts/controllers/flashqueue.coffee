'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:FlashqueueCtrl
 # @description
 # # FlashqueueCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'FlashQueueCtrl', ($scope, flashqueue, undoqueue, game) ->
  $scope.achieveQueue = flashqueue
  $scope.undoQueue = undoqueue

  $scope.verb = (command) ->
    if command.unitname?
      return 'Bought'
    else if command.upgradename?
      upgrade = game.upgrade command.upgradename
      if upgrade.type['class'] == 'ability'
        return 'Cast'
      return 'Bought'

  $scope.num = (command) ->
    return command.twinnum ? command.num

  $scope.label = (command) ->
    if command.unitname?
      unit = game.unit command.unitname
      if $scope.num(command) == 1
        return unit.unittype.label
      return unit.unittype.plural
    else if command.upgradename?
      upgrade = game.upgrade command.upgradename
      return upgrade.type.label

  $scope.undo = (command) ->
    if command.undoExport?
      game.importSave command.undoExport
      undoqueue.clear()
      flashqueue.clear()
