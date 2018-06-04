'use strict'

angular.module('swarmApp').directive 'domainchange', (domainType, wwwRedirectDate, $location, session) ->
  restrict: 'E'
  template: """<div ng-if="!!url" ng-include="url"></div>"""
  link: (scope, element, attrs) ->
    scope.redirectDate = wwwRedirectDate
    scope.redirectDuration = moment.duration(wwwRedirectDate.getTime() - Date.now()).format("d [days]")

    if (domainType == 'oldwww')
      scope.url = "views/domainchange-old.html"
      ts = session.state.date.reified.getTime()
      scope.moveNowUrl = "https://www.swarmsim.com/#/importsplash?ts=#{encodeURIComponent ts}&referrer=github&savedata=#{encodeURIComponent session.exportSave()}"
    else if (domainType == 'www')
      scope.url = "views/domainchange-new.html"
    else
      scope.url = null
