/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import * as views from '../views';

angular.module('swarmApp').directive('focusInput', ($timeout, hotkeys) => ({
  restrict: 'A',

  link(scope, element, attrs) {
    const focus = function(event) {
      element[0].focus();
      return event.preventDefault();
    };
    // autofocus
    // $timeout focus, 0
    // hotkey focus
    return hotkeys.bindTo(scope).add({
      combo: '/',
      description: 'Focus buy-unit input field',
      callback: focus
    });
  }
}));

/**
 * @ngdoc directive
 * @name swarmApp.directive:unit
 * @description
 * # unit
*/
angular.module('swarmApp').directive('unit', ($log, game, options, util, $location, hotkeys) => ({
  template: views.directiveUnit,
  restrict: 'E',

  scope: {
    cur: '='
  },

  link(scope, element, attrs) {
    let upgrade;
    scope.game = game;
    scope.options = options;

    const hk = hotkeys.bindTo(scope);
    if (scope.cur.prev != null) {
      hk.add({
        combo: ['down', 'left'],
        description: 'Select '+scope.cur.prev.type.plural,
        callback(event) {
          $location.path('/unit/'+scope.cur.prev.unittype.slug);
          return event.preventDefault();
        }
      });
    }
    if (scope.cur.next != null) {
      hk.add({
        combo: ['up', 'right'],
        description: 'Select '+scope.cur.next.type.plural,
        callback(event) {
          $location.path('/unit/'+scope.cur.next.unittype.slug);
          return event.preventDefault();
        }
      });
    }

    const formatDuration = function(estimate) {};
    scope.estimateUpgradeSecs = function(upgrade) {
      let left;
      const estimate = upgrade.estimateSecsUntilBuyable();
      const val = estimate.val.toNumber();
      // There are a few reasons this estimate could be infinite:
      // - (1) The estimte is really infinite; one of the producers has a
      //   velocity of zero. Ex. You'll never have enough for an upgrade priced
      //   in drones if you have no queens. Division by zero.
      // - (2) The estimate is larger than 1e308, but smaller than decimal.js's
      //   max. moment.js takes native JS numbers, so these fail.
      // - (3) There's a bug somewhere that returned NaN. Shouldn't happen, but
      //   this code's old and hairy enough that I'm not going to go hunting for
      //   it.
      if (!isFinite(val)) {
        if (estimate.val.isFinite() || estimate.val.isNaN()) {
          // (2) and (3); the moment filter displays this as 'almost forever'
          return NaN;
        }
        // (1); the moment filter displays this as ''
        return Infinity;
      }
      const secs = moment.duration(val, 'seconds');
      //add nonexact annotation for use by filter
      secs.nonexact = !((left = __guardMethod__(estimate.unit, 'isEstimateExact', o => o.isEstimateExact())) != null ? left : true);
      return secs;
    };

    scope.filterVisible = upgrade => upgrade.isVisible();

    scope.watched = {};
    for (upgrade of Array.from(scope.cur.upgrades.byClass.upgrade != null ? scope.cur.upgrades.byClass.upgrade : [])) {
      scope.watched[upgrade.name] = upgrade.watchedAt();
    }
    for (upgrade of Array.from(scope.cur.upgrades.byClass.ability != null ? scope.cur.upgrades.byClass.ability : [])) {
      scope.watched[upgrade.name] = !upgrade.isManuallyHidden();
    }
    scope.updateWatched = upgrade => upgrade.watch(scope.watched[upgrade.name]);
    return scope.updateWatchedAbility = upgrade => upgrade.watch(scope.watched[upgrade.name] ? 0 : -1);
  }
}));

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}