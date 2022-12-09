/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:StatisticsCtrl
 * @description
 * # StatisticsCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('StatisticsCtrl', function($scope, session, statistics, game, options, util) {
  $scope.listener = statistics;
  $scope.session = session;
  $scope.statistics = session.state.statistics;
  $scope.game = game;

  $scope.unitStats = function(unit) {
    const ustatistics = _.clone($scope.statistics.byUnit != null ? $scope.statistics.byUnit[unit != null ? unit.name : undefined] : undefined);
    if (ustatistics != null) {
      ustatistics.elapsedFirstStr = util.utcdoy(ustatistics.elapsedFirst);
    }
    return ustatistics;
  };
  $scope.hasUnitStats = unit => !!$scope.unitStats(unit);
  $scope.showStats = unit => $scope.hasUnitStats(unit) || (!unit.isBuyable() && unit.isVisible());

  $scope.upgradeStats = function(upgrade) {
    const ustatistics = $scope.statistics.byUpgrade[upgrade.name];
    if (ustatistics != null) {
      ustatistics.elapsedFirstStr = util.utcdoy(ustatistics.elapsedFirst);
    }
    return ustatistics;
  };
  return $scope.hasUpgradeStats = upgrade => !!$scope.upgradeStats(upgrade);
});
