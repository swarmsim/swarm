'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, spreadsheet, units) ->
  promise =
    spreadsheet: {}
    units: {}
  spreadsheet.then (result) ->
    _.extend promise.spreadsheet, result
  console.log units
  units.then (result) ->
    promise.units.units = result
  $scope.dumps = [
    {title:'session', data:session}
    {title:'units', data:promise.units}
    {title:'spreadsheet', data:promise.spreadsheet}
    ]
