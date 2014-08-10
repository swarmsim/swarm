'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, session, unittypes) ->
  $scope.session = session
  unittypes.then (unittypes_) =>
    $scope.unittypes = unittypes_
    $scope.click = (name) ->
      unittype = unittypes_.byName[name]
      console.log 'clicked', name, unittype
      console.assert unittype
      unittype.buy session
      session.save()
