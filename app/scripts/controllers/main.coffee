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
  $scope.unittypes = unittypes

  $scope.click = (name) ->
    unittype = $scope.unittypes.byName[name]
    console.log 'clicked', name, unittype
    console.assert unittype
    unittype.buy session
    session.save()
