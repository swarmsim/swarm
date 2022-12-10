'use strict'

angular.module('swarmApp').controller 'ExportCtrl', ($scope, options, session, $log, isKongregate) ->
  $scope.newhost = "www.swarmsim.com"

  $scope.form =
    export: session.exportSave()

  $scope.exporturl = "https://#{$scope.newhost}/#/importsplash?savedata=#{encodeURIComponent $scope.form.export}"

  $scope.select = ($event) ->
    $event.target.select()
