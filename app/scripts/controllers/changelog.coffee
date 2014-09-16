'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:ChangelogCtrl
 # @description
 # # ChangelogCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ChangelogCtrl', ($log, $scope, env) ->
  $scope.$emit 'changelog'
  $scope.env = env
  zone = -8
  $scope.stats =
    _rawheaders: $ '.changelog h4'
    lastHeaders: (days) ->
      _.filter $scope.stats.headers, (header) ->
        header.diffDays < days
  parseheader = (header) ->
    text = $(header).text()
    [version, datestr] = text.split ' '
    date = moment(datestr, 'YYYY/MM/DD').zone zone
    diffDays = moment().zone(zone).diff date, 'days'
    text: text
    version: version
    date: date
    diffDays: diffDays
  $scope.stats.headers = (parseheader(header) for header in $scope.stats._rawheaders)
  [$scope.stats.lastrelease, ..., $scope.stats.firstrelease] = $scope.stats.headers
  $scope.stats.days = $scope.stats.firstrelease?.diffDays
  $log.debug 'changelogdate', $scope.stats
