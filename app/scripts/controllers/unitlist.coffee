'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UnitlistCtrl
 # @description
 # # UnitlistCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UnitlistCtrl', ($scope, $routeParams, $location, $filter, $interval, game) ->
  $scope.game = game
  $scope.action = 'select'
  $scope.buynum = 1
  $scope.mainBuynum = 1
  $scope.selected = if $routeParams.unit? then $scope.game.unit $routeParams.unit else null

  $interval (=>$scope.$apply()), 200

  $scope.select = (unit) ->
    $scope.selected = unit
    #document.location.hash = "/unitlist/#{unittype.name}"
    #$location.path "/unitlist/#{unittype.name}"

  $scope.buy = (unit, quantity=$scope.buynum) ->
    console.assert unit
    console.assert quantity > 0
    # no multi-gathering
    if unit.cost.length == 0
      quantity = Math.min quantity, 1
    try
      unit.buy quantity
    catch e
      # Out-of-money throws an exception. No problem
      # TODO: show an error to the player.
      console.log e

  $scope.costText = (unit) ->
    ret = ("#{$filter('bignum')(cost)} #{cost.unit.unittype.plural}" for name, cost of unit.cost)
    ret = ret.join ", "
    if ret
      ret = "Cost: #{ret}"
    return ret

  $scope.welcomeBackText = ->
    return '' #TODO offline play
    awayMillis = game?.session?.date?.loaded?.getTime?() - game?.session?.date?.saved?.getTime?()
    if (not _.isNaN awayMillis) and awayMillis > 5 * 60 * 1000
      return "Welcome back. Your swarm continued to work hard while you were away."

  $scope.emptyText = ->
    counts = game.counts()
    if (counts.swarmer + counts.devourer) > 0
      return "Your swarm's military and territory both expand rapidly."
    if (counts.swarmer + counts.devourer) > 0
      return "Your nest gives you more food and workers than your swarm has ever known. Swarmers and Locusts will further expand your military, and your territory."
    if (counts.nest > 0)
      return "Your nest gives you more food and workers than your swarm has ever known. Build an army with Swarmers or Locusts and expand your territory further."
    if (counts.stinger + counts.locust) > 0
      return "Your warriors have secured some territory. A nest will further increase the growth rate of your swarm."
    if counts.queen > 0
      return "You are the queen of a growing swarm, and your growth demands more territory. Raise some stingers or locusts to explore and conquer new lands."
    if counts.drone > 0
      return "You lead a small swarm of worker drones. Your fellow drones long for a queen."
    return "You are a single bug, a worker drone with no hive to call home. Begin by gathering food, so you can multiply yourself into more drones."

  $scope.click = (unittype) ->
    $scope[$scope.action](unittype)
