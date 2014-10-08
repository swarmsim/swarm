'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:ChangelogCtrl
 # @description
 # # ChangelogCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ChangelogCtrl', ($log, $scope, env, version, session) ->
  $scope.$emit 'changelog'
  $scope.env = env
  zone = -8
  $scope.changestats =
    _rawheaders: $ '.changelog h4'
    lastHeaders: (days) ->
      _.filter $scope.changestats.headers, (header) ->
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
  $scope.changestats.headers = (parseheader(header) for header in $scope.changestats._rawheaders)
  [$scope.changestats.lastrelease, ..., $scope.changestats.firstrelease] = $scope.changestats.headers
  $scope.changestats.days = $scope.changestats.firstrelease?.diffDays
  $log.debug 'changelogdate', $scope.changestats

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"
