/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:ImportsplashCtrl
 * @description
 * # ImportsplashCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('ImportsplashCtrl', function($scope, isKongregate, game) {
  // header/loadsave do the actual import
  $scope.isKongregate = isKongregate();

  return $scope.click = function() {
    game.withSave(function() {});
    if ($scope.isKongregate) {
      return window.location.href = 'http://www.kongregate.com/games/swarmsim/swarm-simulator';
    } else {
      return window.location = '#/';
    }
  };
});
