'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, game, spreadsheet, env, unittypes) ->
  #console.log game, unittypes
  $scope.dumps = [
    {title:'env', data:env}
    {title:'game', data:!!game}
    {title:'session', data:session}
    {title:'unittypes', data:!!unittypes}
    {title:'spreadsheet', data:spreadsheet}
    ]
  $scope.throwUp = ->
    throw new Error "throwing up (test exception)"
  $scope.session = session
  $scope.game = game
  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. You sure?'
      game.reset()
