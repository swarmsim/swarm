/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:ChangelogCtrl
 * @description
 * # ChangelogCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('ChangelogCtrl', function($log, $scope, env, version) {
  let header;
  $scope.$emit('changelog');
  $scope.env = env;
  const zone = -8;
  $scope.changestats = {
    _rawheaders: $('.changelog h4'),
    lastHeaders(days) {
      return _.filter($scope.changestats.headers, header => header.diffDays < days);
    }
  };

  const parseheader = function(header) {
    const text = $(header).text();
    const [ver, datestr] = Array.from(text.split(' '));
    const date = moment(datestr, 'YYYY/MM/DD').zone(zone);
    const diffDays = moment().zone(zone).diff(date, 'days');
    return {
      text,
      version: ver,
      date,
      diffDays
    };
  };
  $scope.changestats.headers = ((() => {
    const result = [];
    for (header of Array.from($scope.changestats._rawheaders)) {       result.push(parseheader(header));
    }
    return result;
  })());
  $scope.changestats.lastrelease = $scope.changestats.headers[0],
    $scope.changestats.firstrelease = $scope.changestats.headers[$scope.changestats.headers.length - 1];
  $scope.changestats.days = $scope.changestats.firstrelease != null ? $scope.changestats.firstrelease.diffDays : undefined;
  return $log.debug('changelogdate', $scope.changestats);
});
