'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UnitCtrl
 # @description
 # # UnitCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UnitCtrl', ($scope, $log, $routeParams, $location, game, commands, hotkeys) ->
  $scope.game = game
  $scope.commands = commands
  $scope.cur = $scope.game.unitByLabel $routeParams.unit
  if (not $scope.cur?) or (not $scope.cur.isVisible())
    $location.url '/'
  $log.debug $scope.cur

  # a goto oh noes
  goto = (unit) ->
    if unit and unit.isVisible()
      $location.url "/unit/#{unit.unittype.label}"
  $scope.swipe = goto

  # https://github.com/chieffancypants/angular-hotkeys/
  binds = hotkeys.bindTo $scope
  binds.add
    combo: 'left'
    description: 'Go to previous unit'
    callback: ->
      goto $scope.cur?.prev
  binds.add
    combo: 'right'
    description: 'Go to next unit'
    callback: ->
      goto $scope.cur?.next
  binds.add
    combo: 'esc'
    description: "Return to '#{$scope.cur.tab.name}' tab"
    callback: ->
      $location.url "/tab/#{$scope.cur.tab.name}"
