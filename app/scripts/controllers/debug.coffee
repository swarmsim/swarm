'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, schedule, spreadsheet, unittypes) ->
  promise =
    spreadsheet: {}
    unittypes: {}
  spreadsheet.then (result) ->
    _.extend promise.spreadsheet, result
  console.log unittypes
  unittypes.then (result) ->
    promise.unittypes.unittypes = result
  $scope.dumps = [
    {title:'session', data:session}
    {title:'unittypes', data:promise.unittypes}
    {title:'spreadsheet', data:promise.spreadsheet}
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
