'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:crystalTimer
 # @description
 # # crystalTimer
###
angular.module('swarmApp').directive 'crystalTimer', (game) ->
  restrict: 'E'
  template: """
<div ng-if="isVisible()">
<p ng-if="unit.isAddUnitTimerReady(crystalTimerDurationMillis())">
  Your next {{unittext}} will award {{crystalTimerQuantity()}} crystals.
</p>
<p ng-if="!unit.isAddUnitTimerReady(crystalTimerDurationMillis())">
  After {{unit.addUnitTimerRemainingMillis(crystalTimerDurationMillis()) | duration}},
  your next {{unittext}} will award {{crystalTimerQuantity()}} crystals.
</p>
</div>
"""
  scope:
    unittext: '=?'
  link: (scope, element, attrs) ->
    scope.unit = game.unit 'crystal'
    scope.unittext ?= 'hatchery or expansion'

    scope.isVisible = ->
      return game.unit('energy').isVisible()
    effect = ->
      upgrade = game.upgrade 'hatchery' # expansion would also work
      return upgrade.effectByType.addUnitTimed[0]
    scope.crystalTimerDurationMillis = -> effect().val2 * 1000
    scope.crystalTimerQuantity = -> effect().val
