'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tutorial
 # @description
 # # tutorial
###
angular.module('swarmApp').directive 'tutorial', (game) ->
  template: """
    <div ng-if="tutText()" class="alert animif alert-info" role="alert">
      <!--button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button-->
      {{tutText()}}
    </div>
  """
  scope:
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.tutText = ->
      game_ = scope.game ? game
      units = game_.countUnits()
      upgrades = game_.countUpgrades()
      if upgrades.expansion >= 5
        return null
      if upgrades.expansion > 0
        return "Expansion is the key to growing your swarm rapidly. Build a large military to expand your territory and produce more larvae. Build more queens and, eventually, nests to produce more meat for your military."
      if upgrades.hatchery > 0
        if units.queen >= 5
          if units.territory > 50
            return "Your warriors have captured a lot of territory, and soon you can secure your first expansion. Expansions increase larva production. Select 'Larva' to expand."
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
      return "Your brood starts its life with a small pile of meat and a single larva-producing hatchery. Larvae mutate into other units. Begin your growth by using your meat and larvae to hatch some drones."
