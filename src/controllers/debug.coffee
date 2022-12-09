'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, game, spreadsheet, env, unittypes, flashqueue, $timeout, $log, util) ->
  $scope.$emit 'debugPage'

  if not env.isDebugEnabled
    return

  $scope.dumps = [
    {title:'env', data:env}
    {title:'game', data:!!game}
    {title:'session', data:session}
    {title:'unittypes', data:!!unittypes}
    {title:'spreadsheet', data:spreadsheet}
    ]

  $scope.notify = flashqueue
  $scope.achieve = ->
    $scope.notify.push {type:{label:'fake achievement',longdesc:'yay'}, pointsEarned:(-> 42), description:(-> 'wee')}

  $scope.throwUp = ->
    throw new Error "throwing up (test exception)"
  $scope.assertFail = ->
    util.assert false, "throwing up (test assertion failure)"
  $scope.error = ->
    util.error "throwing up (test util.error)"
  $scope.form = {}
  $scope.session = session
  $scope.$watch 'form.session', (text, text0) ->
    if text != text0
      $log.debug 'formsession update', text, $scope.session._saves text, false
      $scope.session.importSave $scope.session._saves JSON.parse(text), false
    else
      $log.debug 'formsession equal'
  $scope.$watch 'session', do ->
    $log.debug 'session update'
    $scope.form.sessionExport = $scope.session.exportSave()
    $scope.form.session = JSON.stringify $scope.session._loads($scope.form.sessionExport), undefined, 2
  $scope.game = game
  $scope.env = env
  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. You sure?'
      game.reset()
