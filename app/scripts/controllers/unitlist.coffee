'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UnitlistCtrl
 # @description
 # # UnitlistCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UnitlistCtrl', ($scope, $routeParams, $location, session, $filter, _unittypes_) ->
  $scope.session = session

  $scope.select = (unittype) ->
    $scope.selected = unittype
    #document.location.hash = "/unitlist/#{unittype.name}"
    #$location.path "/unitlist/#{unittype.name}"

  $scope.buy = (unittype, quantity=$scope.buynum) ->
    console.assert unittype
    console.assert quantity > 0
    for i in [0...quantity]
      unittype.buy session
    session.save()

  $scope.costtext = (unittype) ->
    ret = ("#{$filter('bignum')(cost)} #{$scope.unittypes.byName[name].label}" for name, cost of unittype.totalCost session)
    ret = ret.join ", "
    if ret
      ret = "Cost: #{ret}"
    return ret

  $scope.action = 'select'
  $scope.buynum = 1

  $scope.click = (unittype) ->
    $scope[$scope.action](unittype)

  # TODO make select use routing
  _unittypes_.then (unittypes) =>
    $scope.selected = unittypes.byName[$routeParams.unit]
    $scope.unittypes = unittypes
