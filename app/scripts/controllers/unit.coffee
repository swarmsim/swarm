'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UnitCtrl
 # @description
 # # UnitCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UnitCtrl', ($scope, $log, util, $routeParams, $location, game, options, commands) ->
  $scope.game = game
  $scope.commands = commands
  $scope.cur = $scope.game.unitByLabel $routeParams.unit
  if (not $scope.cur?) or (not $scope.cur.isVisible())
    $location.url '/main2'
  $log.debug $scope.cur

  $scope.form =
    mainBuynum: 1
  $scope.mainBuynum = ->
    ret = Math.max 1, Math.floor $scope.form.mainBuynum
    if _.isNaN ret
      ret = 1
    return ret
  $scope.unitBuyTotal = (num) ->
    Math.min(num, $scope.cur.maxCostMet()) * $scope.cur.stat 'twin', 1
  $scope.swipe = (unit) ->
    if unit and unit.isVisible()
      $location.url "/unit/#{unit.unittype.label}"

  util.animateController $scope, game:game, options:options
