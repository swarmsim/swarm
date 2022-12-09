/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:LoginCtrl
 * @description
 * # LoginCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('LoginCtrl', function($scope, loginApi) {
  $scope.form = {};
  return $scope.submit = () => loginApi.login('local', $scope.form);
});
