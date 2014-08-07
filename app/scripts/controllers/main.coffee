'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, session, _unittypes_) ->
  $scope.session = session
  _unittypes_.then (unittypes) =>
    $scope.unittypes = unittypes
    $scope.click = (name) ->
      unittype = unittypes.byName[name]
      console.log 'clicked', name, unittype
      console.assert unittype
      try
        unittype.buy session
      catch e
        console.error e
