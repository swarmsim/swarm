'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, game, spreadsheet, env, unittypes, flashqueue, $timeout) ->
  console.log 'debugs', game, unittypes
  $scope.dumps = [
    {title:'env', data:env}
    {title:'game', data:!!game}
    {title:'session', data:session}
    {title:'unittypes', data:!!unittypes}
    {title:'spreadsheet', data:spreadsheet}
    ]

  $scope.notify = flashqueue
  $timeout (->$scope.notify.push {label:'hihi', points:10, description:'ahaha'}), 1000

  $scope.throwUp = ->
    throw new Error "throwing up (test exception)"
  $scope.form = {}
  $scope.session = session
  $scope.$watch 'form.session', (text, text0) ->
    if text != text0
      console.log 'formsession update', text, $scope.session._saves text, false
      $scope.session.importSave $scope.session._saves JSON.parse(text), false
    else
      console.log 'formsession equal'
  $scope.$watch 'session', do ->
    console.log 'session update'
    $scope.form.sessionExport = $scope.session.exportSave()
    $scope.form.session = JSON.stringify $scope.session._loads($scope.form.sessionExport), undefined, 2
  $scope.game = game
  $scope.env = env
  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. You sure?'
      game.reset()
