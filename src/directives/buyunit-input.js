/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:buyunitInput
 * @description
 * # buyunitInput
*/
angular.module('swarmApp').directive('buyunitInput', ($log, commands, options, $location, parseNumber) => ({
  template: views.buyunitInput,
  restrict: 'E',

  scope: {
    unit: '='
  },

  link(scope, element, attrs) {
    scope.commands = commands;
    scope.options = options;

    scope.form = {buyCount:''};
    const search = $location.search();
    if (search.num != null) {
      scope.form.buyCount = search.num;
    } else if (search.twinnum != null) {
      // legacy format - our code doesn't use `?twinnum=n` anymore, but it used to. some users might still use it.
      scope.form.buyCount = `=${search.twinnum}`;
    }

    let _buyCount = new Decimal(1);
    scope.buyCount = function() {
      let left;
      const parsed = (left = parseNumber(scope.form.buyCount || '1', scope.unit)) != null ? left : new Decimal(1);
      // caching required for angular
      if (!parsed.equals(_buyCount)) {
        _buyCount = parsed;
      }
      return _buyCount;
    };

    scope.unitCostAsPercent = function(unit, cost) {
      const MAX = new Decimal(9999.99);
      const count = cost.unit.count();
      if (count.lessThanOrEqualTo(0)) {
        return MAX;
      }
      const num = Decimal.max(1, unit.maxCostMet());
      return Decimal.min(MAX, cost.val.times(num).dividedBy(count));
    };
  
    return scope.unitCostAsPercentOfVelocity = function(unit, cost) {
      const MAX = new Decimal(9999.99);
      const count = cost.unit.velocity();
      if (count.lessThanOrEqualTo(0)) {
        return MAX;
      }
      return Decimal.min(MAX, cost.val.times(unit.maxCostMetOfVelocity()).dividedBy(count));
    };
  }
}));
