/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

angular.module('swarmApp').filter('encodeURIComponent', () => text => window.encodeURIComponent(text));

/**
 * @ngdoc directive
 * @name swarmApp.directive:cost
 * @description
 * # cost
*/
angular.module('swarmApp').directive('cost', $log => ({
  restrict: 'E',

  scope: {
    costlist: '=',
    num: '=?',
    buybuttons: '=?',
    noperiod: '=?'
  },

  template: `\
<span ng-repeat="cost in costlist track by cost.unit.name">
  <span ng-if="!$first && $last"> and </span>
  <a ng-if="isRemainingBuyable(cost)" ng-href="\#{{cost.unit.url()}}?num={{'@'+totalCostVal(cost)|encodeURIComponent}}">
    {{totalCostVal(cost) | bignum}} {{totalCostVal(cost) == 1 ? cost.unit.unittype.label : cost.unit.unittype.plural}}<!--whitespace
  --></a><span ng-if="!isRemainingBuyable(cost)" ng-class="{costNotMet:!isCostMet(cost)}">
    {{totalCostVal(cost) | bignum}} {{totalCostVal(cost) == 1 ? cost.unit.unittype.label : cost.unit.unittype.plural}}<!--whitespace
  --></span><span ng-if="$last && !noperiod">.</span><span ng-if="!$last && costlist.length > 2">, </span>
</span>\
`,

  link(scope, element, attrs) {
    if (scope.num == null) { scope.num = 1; }
    scope.totalCostVal = cost => // stringifying scope.num is important to avoid decimal.js precision errors
    cost.val.times(scope.num+'');
    scope.isCostMet = cost => cost.unit.count().greaterThanOrEqualTo(scope.totalCostVal(cost));
    scope.countRemaining = cost => scope.totalCostVal(cost).minus(cost.unit.count()).ceil();
    return scope.isRemainingBuyable = function(cost) {
      // there is a cost remaining that we can't afford, but the remaining units are buyable. Can't necessarily afford them, even one.
      const remaining = scope.countRemaining(cost);
      const isBuyable = cost.unit.isBuyable(true) && cost.unit.isBuyButtonVisible();
      // special case: energy will redirect to crystals, where energy is buyable
      return ((remaining.greaterThan(0) && isBuyable) || (cost.unit.name === 'energy'));
    };
  }
}));
