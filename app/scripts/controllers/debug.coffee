'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, schedule, spreadsheet, env, unittypes) ->
  $scope.dumps = [
    {title:'env', data:env}
    {title:'session', data:session}
    {title:'unittypes', data:unittypes}
    {title:'spreadsheet', data:spreadsheet}
    ]
  $scope.throwUp = ->
    throw new Error "throwing up (test exception)"
  $scope.session = session
  $scope.schedule = schedule
  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. You sure?'
      schedule.pause()
      session.reset()
      schedule.unpause()
