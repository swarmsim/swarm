/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc directive
 * @name swarmApp.directive:crystalTimer
 * @description
 * # crystalTimer
*/
angular.module('swarmApp').directive('crystalTimer', game => ({
  restrict: 'E',

  template: `\
<div ng-if="isVisible()">
<p ng-if="unit.isAddUnitTimerReady(crystalTimerDurationMillis())">
  Your next {{unittext}} will award {{crystalTimerQuantity()}} crystals.
</p>
<p ng-if="!unit.isAddUnitTimerReady(crystalTimerDurationMillis())">
  After {{unit.addUnitTimerRemainingMillis(crystalTimerDurationMillis()) | duration}},
  your next {{unittext}} will award {{crystalTimerQuantity()}} crystals.
</p>
</div>\
`,

  scope: {
    unittext: '=?'
  },

  link(scope, element, attrs) {
    scope.unit = game.unit('crystal');
    if (scope.unittext == null) { scope.unittext = 'hatchery or expansion'; }

    scope.isVisible = () => game.unit('energy').isVisible();
    const effect = function() {
      const upgrade = game.upgrade('hatchery'); // expansion would also work
      return upgrade.effectByType.addUnitTimed[0];
    };
    scope.crystalTimerDurationMillis = () => effect().val2 * 1000;
    return scope.crystalTimerQuantity = () => effect().val;
  }
}));
