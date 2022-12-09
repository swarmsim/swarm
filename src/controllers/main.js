/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
// TODO this breaks ...something
import _ from 'lodash';

/**
 * @ngdoc function
 * @name swarmApp.controller:Main2Ctrl
 * @description
 * # Main2Ctrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('MainCtrl', function($scope, $log, game, $routeParams, $location, version, options, hotkeys) {
  let left;
  $scope.game = game;
  $scope.options = options;

  // special case: buy-energy links redirect to crystals
  if (($routeParams.unit === 'energy') && ($routeParams.tab === 'energy') && ($location.search().num != null)) {
    // console.log 'hellohello', $location.search().num
    $location.path('/tab/energy/unit/crystal');
  }
  
  $scope.cur = {};
  $scope.cur.unit = $scope.game.unitBySlug($routeParams.unit);
  $scope.cur.tab = (left = $scope.game.tabs.byName[$routeParams.tab] != null ? $scope.game.tabs.byName[$routeParams.tab] : ($scope.cur.unit != null ? $scope.cur.unit.tab : undefined)) != null ? left : $scope.game.tabs.list[0];
  $scope.cur.tab.lastselected = $scope.cur.unit;
  // if it's a bogus tab name, or the tab's not visible (ex. energy before first nexus)
  if ((($routeParams.tab !== $scope.cur.tab.name) && ($routeParams.tab != null)) || !$scope.cur.tab.isVisible()) {
    $location.url('/');
  }
  // if they asked for a unit but that unit has issues, redirect to no-unit
  if (($routeParams.unit != null) && (
    ($scope.cur.unit == null) ||
    // they gave a bogus unit as a url parameter
    ($scope.cur.unit.unittype.slug !== $routeParams.unit) ||
    // they gave a unit that's not in this tab. comparing to unit.tab breaks /tab/all
    ($scope.cur.tab.indexByUnitName[$scope.cur.unit.name] == null) ||
    // the unit they asked for isn't visible yet
    !$scope.cur.unit.isVisible()
  )) {

    $log.debug('invalid unit', $routeParams.unit, $scope.cur.unit, (($scope.cur.unit == null)), __guard__($scope.cur.unit != null ? $scope.cur.unit.unittype : undefined, x => x.slug) !== $routeParams.unit, ($scope.cur.tab.indexByUnitName[$scope.cur.unit != null ? $scope.cur.unit.name : undefined] == null), !__guardMethod__($scope.cur.unit, 'isVisible', o => o.isVisible()));
    $location.url($scope.cur.tab.url(false));
  }
  $log.debug('tab', $scope.cur);

  $scope.click = unit => $location.url($scope.cur.tab.url(unit));

  $scope.filterVisible = unit => unit.isVisible();

  var findtab = function(index, step) {
    index += step + game.tabs.list.length;
    index %= game.tabs.list.length;
    const tab = game.tabs.list[index];
    if (tab === $scope.cur.tab) {
      return null;
    }
    if (tab.isVisible()) {
      return tab;
    }
    return findtab(index, step);
  };

  const hk = hotkeys.bindTo($scope);
  let keys = '1234567890';
  // shift+<n> for 11-20
  keys = keys.split('').concat(keys.split('').map(k => 'shift+'+k));
  return (() => {
    const result = [];
    const iterable = _.reverse(_.filter($scope.cur.tab.sortUnits(), $scope.filterVisible));
    for (let i = 0; i < iterable.length; i++) {
      var unit = iterable[i];
      result.push((function(unit, i) {
        if (keys[i] != null) {
          return hk.add({
            combo: keys[i],
            // clutters the screen
            //description: 'Select '+unit.type.plural
            callback() {
              return $location.path('/unit/'+unit.type.slug);
            }
          });
        }
      })(unit, i));
    }
    return result;
  })();
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}