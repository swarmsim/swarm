'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tutorial
 # @description
 # # tutorial
###
angular.module('swarmApp').directive 'tutorial', (game, env) ->
  template: """
    <div ng-if="tutStep() > 0" class="alert animif alert-info" role="alert">
      <button ng-if="showCloseButton()" type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>

      <div ng-if="tutStep() == 1">
        <p>Welcome to Swarm Simulator. Starting with just a few larvae and a small pile of meat, grow a massive swarm of giant bugs.</p>
        <p>Your brood starts its life with a small pile of meat and a single larva-producing hatchery. Larvae mutate into other units. Begin your growth by using your meat and larvae to hatch some <a href="#/unit/drone">drones</a>.</p>
      </div>
      <p ng-if="tutStep() == 2">You lead a small brood of worker drones. Drones gather meat. Use this meat to build more drones and expand your brood.</p>
      <p ng-if="tutStep() == 3">You lead a small brood of worker drones. Once you have plenty of meat, upgrade your hatchery to produce more larvae by selecting '<a href="#/unit/larva">larvae</a>' and spending some meat.</p>
      <p ng-if="tutStep() == 4">You lead a small brood of worker drones. They long for a <a href="#/unit/queen">queen</a>. You must sacrifice many drones to hatch a queen, but once born, your queen will slowly hatch drones without consuming meat or larvae.</p>
      <p ng-if="tutStep() == 5">Hatch more queens to grow your swarm. Hatching drones with the "Twin Drones" upgrade will allow you to rapidly raise more queens.</p>
      <p ng-if="tutStep() == 6">Queens have rapidly grown your swarm, and your growth demands more <a href="#/unit/territory">territory</a>. Begin capturing <a href="#/unit/territory">territory</a> by building military units - swarmlings or stingers.</p>
      <p ng-if="tutStep() == 7">Your warriors have slowly begun securing territory. Continue expanding your military.</p>
      <p ng-if="tutStep() == 8">Your warriors have captured a lot of territory, and soon you can secure your first expansion. Expansions increase larva production. Select '<a href="#/unit/larva">larvae</a>' to expand.</p>
      <p ng-if="tutStep() == 9">Expansion is the key to growing your swarm rapidly. Build a large military to expand your territory and produce more larvae. Build more queens and, eventually, nests to produce more meat for your military.</p>

      <p ng-if="tutStep() == 10">Your swarm has grown large enough to <b>ascend</b> - gain even greater power and restart on a new world! Take a look at the <a href="#/unit/mutagen">mutagen tab</a>.</p>
    </div>
  """
  scope:
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    game_ = scope.game ? game
    scope.showCloseButton = ->
      return scope.tutStep() == 10
    scope.tutStep = ->
      return game.cache.tutorialStep ?= do =>
        units = game_.countUnits()
        upgrades = game_.countUpgrades()
        if !units.ascension.isZero()
          # No tutorial messages after first ascension.
          return 0
        if game_.cache.firstSpawn.premutagen and units.ascension.isZero()
          return 10
        if upgrades.expansion.greaterThanOrEqualTo(5)
          return 0
        if upgrades.expansion.greaterThan(0)
          return 9
        if upgrades.hatchery.greaterThan(0)
          if units.queen.greaterThanOrEqualTo(5)
            if units.territory.greaterThan(5)
              return 8
            if units.territory.greaterThan(0)
              return 7
            return 6
          if units.queen.greaterThan(0)
            return 5
        if units.drone.greaterThanOrEqualTo(10)
          if upgrades.hatchery.greaterThan(0)
            return 4
          return 3
        if units.drone.greaterThan(0)
          return 2
        return 1

    if env.isOffline
      scope.tutStep = ->
        return 0
