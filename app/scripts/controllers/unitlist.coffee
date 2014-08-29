'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:UnitlistCtrl
 # @description
 # # UnitlistCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UnitlistCtrl', ($scope, $routeParams, $location, $filter, $interval, game, options, commands) ->
  $scope.game = game
  $scope.commands = commands
  $scope.action = 'select'
  $scope.buynum = 1
  $scope.mainBuynum = 1
  $scope.selected = if $routeParams.unit? then $scope.game.unit $routeParams.unit else null

  # fps may change in options menu, but we destroy the interval upon loading the options menu, so no worries
  animatePromise = $interval (=>$scope.game.tick()), options.fpsSleepMillis()
  $scope.$on '$destroy', =>
    $interval.cancel animatePromise

  # TODO this should really be a filter
  $scope.decimals = (num) ->
    # Up to two decimal places for small numbers, no decimals for large numbers
    if num > 100
      return Math.floor num
    # http://stackoverflow.com/questions/7312468/javascript-round-to-a-number-of-decimal-places-but-strip-extra-zeros 
    num.toPrecision(3).replace /\.?0+$/, ''

  unitsByGroup = {}
  for unit in $scope.game.unitlist()
    unitsByGroup[unit.unittype.column] ?= []
    unitsByGroup[unit.unittype.column].push unit
  $scope.visibleUnitGroup = (groupnum) ->
    (unit for unit in unitsByGroup[groupnum] ? [] when unit.isVisible())
  $scope.isVisible = (upgrade) ->
    upgrade.isVisible()
  $scope.isWarningVisible = (warn) ->
    warn.unit.count() <= warn.val

  $scope.select = (unit) ->
    $scope.selected = unit
    #document.location.hash = "/unitlist/#{unittype.name}"
    #$location.path "/unitlist/#{unittype.name}"

  $scope.costText = (unit) ->
    ret = ("#{$filter('bignum')(cost.val)} #{cost.unit.unittype.plural}" for name, cost of unit.cost)
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
  $scope.tutText = ->
    units = game.countUnits()
    upgrades = game.countUpgrades()
    if upgrades.expansion >= 5
      return null
    if upgrades.expansion > 0
      return "Expansion is the key to growing your swarm rapidly. Build a large military to expand your territory and produce more larvae. Build more queens and, eventually, nests to produce more meat for your military."
    if upgrades.hatchery > 0
      if units.queen >= 5
        if units.territory > 50
          return "Your warriors have captured a lot of territory, and soon you can secure your first expansion. Expansions increase larvae production. Select 'Larva' to expand."
        if units.territory > 0
          return "Your warriors have slowly begun securing territory. Continue expanding your military."
        return "Queens have rapidly grown your swarm, and your growth demands more territory. Begin capturing territory by building military units - swarmlings or stingers."
      if units.queen > 0
        return "Hatch more queens to grow your swarm. Hatching drones with the \"Twin Drones\" upgrade will allow you to rapidly raise more queens."
    if units.drone >= 10
      if upgrades.hatchery > 0
        return "You lead a small brood of worker drones. They long for a queen. You must sacrifice many drones to hatch a queen, but once born, your queen will slowly hatch drones without consuming meat or larvae."
      return "You lead a small brood of worker drones. Once you have plenty of meat, upgrade your hatchery to produce more larvae by selecting 'Larva' and spending some meat."
    if units.drone > 0
      return "You lead a small brood of worker drones. Drones gather meat. Use this meat to build more drones and expand your brood."
    return "Your brood starts its life with a small pile of meat and a single larvae-producing hatchery. Larvae mutate into other units. Begin your growth by using your meat and larvae to hatch some drones."

  $scope.buy = (unit) -> $scope.commands.buyUnit unit, $scope.buynum
  $scope.buyMax = (unit) -> $scope.commands.buyMaxUnit unit
  $scope.click = (unittype) ->
    $scope[$scope.action](unittype)
