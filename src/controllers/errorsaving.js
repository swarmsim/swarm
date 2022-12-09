/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:ErrorsavingCtrl
 * @description
 * # ErrorsavingCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('ErrorSavingCtrl', function($scope, game, $rootScope) {
  let failCount;
  let successCount = (failCount = 0);

  $scope.game = game;
  $scope.form = {};

  $scope.$on('save', () => successCount += 1);
  $scope.$on('save:failed', function(e, data) {
    failCount += 1;
    if (successCount === 0) {
      $scope.form.errored = true;
      $scope.form.error = data.error != null ? data.error.message : undefined;
      return $scope.form.export = game.session.exportSave();
    }
  });

  // http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  return $scope.select = $event => $event.target.select();
});
