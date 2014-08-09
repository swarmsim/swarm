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
  $scope.selected = null

  $scope.select = (unittype) ->
    $scope.selected = unittype
    #document.location.hash = "/unitlist/#{unittype.name}"
    #$location.path "/unitlist/#{unittype.name}"

  $scope.unitCount = (name) ->
    return Math.floor $scope.session.unittypes[name]

  $scope.buy = (unittype, quantity=$scope.buynum) ->
    console.assert unittype
    console.assert quantity > 0
    # no multi-gathering
    if unittype.cost.length == 0
      quantity = Math.min quantity, 1
    try
      for i in [0...quantity]
        unittype.buy session
    catch e
      # Out-of-money throws an exception. No problem
      # TODO: show an error to the player.
      console.log e
    session.save()

  $scope.costtext = (unittype) ->
    ret = ("#{$filter('bignum')(cost)} #{$scope.unittypes.byName[name].plural}" for name, cost of unittype.totalCost session)
    ret = ret.join ", "
    if ret
      ret = "Cost: #{ret}"
    return ret

  $scope.action = 'select'
  $scope.buynum = 1
  $scope.mainBuynum = 1

  $scope.emptyText = ->
    if (session.unittypes.swarmer + session.unittypes.devourer > 0)
      return "Your swarm's military and territory both expand rapidly."
    if (session.unittypes.swarmer + session.unittypes.devourer > 0)
      return "Your nest gives you more food and workers than your swarm has ever known. Swarmers and Locusts will further expand your military, and your territory."
    if (session.unittypes.nest > 0)
      return "Your nest gives you more food and workers than your swarm has ever known. Build an army with Swarmers or Locusts and expand your territory further."
    if (session.unittypes.stinger + session.unittypes.locust) > 0
      return "Your warriors have secured some territory. A nest will further increase the growth rate of your swarm."
    if session.unittypes.queen > 0
      return "You are the queen of a growing swarm, and your growth demands more territory. Raise some stingers or locusts to explore and conquer new lands."
    if session.unittypes.drone > 0
      return "You lead a small swarm of worker drones. Your fellow drones long for a queen."
    return "You are a single bug, a worker drone with no hive to call home. Begin by gathering food, so you can multiply yourself into more drones."

  $scope.click = (unittype) ->
    $scope[$scope.action](unittype)

  # TODO make select use routing
  _unittypes_.then (unittypes) =>
    $scope.selected = unittypes.byName[$routeParams.unit]
    $scope.unittypes = unittypes
