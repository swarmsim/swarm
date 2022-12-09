/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:description
 * @description
 *
 * Use either static descriptions from the spreadsheet, or templated descriptions in /app/views/desc.
 * Spreadsheet descriptions of '' or '-' indicate that we should try to use a template.
 * (We used to do stupid $compile tricks to allow templating in the spreadsheet, but that caused memory leaks. #177)
*/
angular.module('swarmApp').directive('unitdesc', (game, commands, options) => ({
  template: '<p ng-if="templateUrl" ng-include="templateUrl" class="desc desc-unit desc-template desc-{{unit.name}}"></p><p ng-if="!templateUrl" class="desc desc-unit desc-text desc-{{unit.name}}">{{desc}}</p>',

  scope: {
    unit: '=',
    game: '=?'
  },

  restrict: 'E',

  link(scope, element, attrs) {
    if (scope.game == null) { scope.game = game; }
    scope.commands = commands;
    scope.options = options;
    return scope.desc = scope.unit.unittype.description;
  }
}));
    // TODO
    //scope.templateUrl = do ->
    //  if scope.desc == '-' or not scope.desc
    //    return "views/desc/unit/#{scope.unit.name}.html"
    //  return ''

angular.module('swarmApp').controller('MtxDesc', function($scope, $log, mtx, commands, $location) {
  $scope.mtx = mtx;

  const pull = function() {
    $scope.pullLoading = true;
    return $scope.mtx.pull()
    .then(function() {
      $scope.pullLoading = false;
      $scope.pullSuccess = true;
      $scope.pullTx = $location.search().tx;
      return $scope.pullError = null;}).catch(function(error) {
      $scope.pullLoading = false;
      $scope.pullSuccess = false;
      $scope.pullTx = $location.search().tx;
      return $scope.pullError = error;
    });
  };

  $scope.mtx.packs()
  .then(function(mtxPacks) {
    $scope.packs = mtxPacks;
    $scope.packsError = null;
    return pull();}).catch(function(error) {
    $scope.packs = null;
    return $scope.packsError = error;
  });
    // don't even bother trying to pull purchases if buy-buttons failed

  $scope.buyLoading = false;
  return $scope.clickBuyPack = function(pack) {
    $scope.buySuccess = ($scope.buyError = null);
    $scope.buyLoading = true;
    return $scope.mtx.buy(pack.name)
    .then(function(res) {
      $scope.buySuccess = true;
      $scope.buyError = null;
      return $scope.buyLoading = false;}).catch(function(error) {
      $log.error('buyerror', error);
      $scope.buySuccess = false;
      $scope.buyError = error;
      return $scope.buyLoading = false;
    });
  };
});

angular.module('swarmApp').directive('upgradedesc', (game, commands, options) => ({
  template: '<p ng-if="templateUrl" ng-include="templateUrl" desc desc-upgrade desc-template desc-{{upgrade.name}}"></p><p ng-if="!templateUrl" class="desc desc-upgrade desc-text desc-{{upgrade.name}}">{{desc}}</p>',

  scope: {
    upgrade: '=',
    game: '=?'
  },

  restrict: 'E',

  link(scope, element, attrs) {
    if (scope.game == null) { scope.game = game; }
    scope.commands = commands;
    scope.options = options;
    return scope.desc = scope.upgrade.type.description;
  }
}));
    // TODO
    //scope.templateUrl = do ->
    //  if scope.desc == '-' or not scope.desc
    //    return "views/desc/upgrade/#{scope.upgrade.name}.html"
    //  return ''
