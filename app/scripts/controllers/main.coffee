'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, session, schedule, _units_) ->
  $scope.session = session
  _units_.then (units) =>
    $scope.units = units
    $scope.click = (resource) ->
      unit = units.byName[resource]
      console.log 'clicked', resource, unit
      console.assert unit
      try
        unit.buy session, resource
      catch e
        console.error e
