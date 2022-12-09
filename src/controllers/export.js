/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

angular.module('swarmApp').controller('ExportCtrl', function($scope, options, session, $log, isKongregate) {
  $scope.newhost = "www.swarmsim.com";

  $scope.form =
    {export: session.exportSave()};

  $scope.exporturl = `https://${$scope.newhost}/#/importsplash?savedata=${encodeURIComponent($scope.form.export)}`;

  return $scope.select = $event => $event.target.select();
});
