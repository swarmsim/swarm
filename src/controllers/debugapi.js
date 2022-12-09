/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:DebugapiCtrl
 * @description
 * # DebugapiCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('DebugApiCtrl', function($scope, env, loginApi, $http, $log) {
  $scope.env = env;
  $scope.loginApi = loginApi;
  $scope.form = {url:'/whoami'};

  $scope.calling = false;
  const appendResult = text => $('<pre>').text(text).prependTo('#testApiCallResults');
  const submitApiCall = (window.submitApiCall = function(request) {
    if ($scope.calling) {
      appendResult('already calling an api. please be patient.');
      return $log.error('already calling an api. please be patient.');
    }
    $log.info('debugapi request', request);
    $scope.calling = new Date();
    return $http(request)
    .success(function(data, status, xhr) {
      const dur = new Date().getTime() - $scope.calling.getTime();
      $scope.calling = false;
      $log.info('debugapi response', data, status, xhr);
      return appendResult(`success: ${status}, ${dur}ms\n\n${JSON.stringify(data, null, 2)}`);}).error(function(data, status, xhr) {
      const dur = new Date().getTime() - $scope.calling.getTime();
      $scope.calling = false;
      $log.warn('debugapi error', data, status, xhr);
      return appendResult(`ERROR: ${status}, ${dur}ms\n\n${JSON.stringify(data, null, 2)}`);
    });
  });

  return $scope.submitApiCall = method => submitApiCall({
    method,
    url: `${env.saveServerUrl}${$scope.form.url}`,
    headers: $scope.form.headers,
    data: $scope.form.data
  });
});
