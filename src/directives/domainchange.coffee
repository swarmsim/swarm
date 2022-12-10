'use strict'
import * as views from '../views'
# import moment from 'moment'

angular.module('swarmApp').directive 'domainchange', (domainType, wwwRedirectDate, $location, session) ->
  restrict: 'E'
  template: """<div ng-if="!!url" ng-include="url"></div>"""
  link: (scope, element, attrs) ->
    scope.redirectDate = wwwRedirectDate
    scope.redirectDuration = window.moment.duration(wwwRedirectDate.getTime() - Date.now()).format("d [days]")

    if (domainType == 'oldwww')
      # TODO
      # scope.url = "views/domainchange-old.html"
      ts = session.state.date.reified.getTime()
      scope.moveNowUrl = "https://www.swarmsim.com/#/importsplash?ts=#{encodeURIComponent ts}&referrer=github&savedata=#{encodeURIComponent session.exportSave()}"
    else if (domainType == 'www')
      # scope.url = "views/domainchange-new.html"
      scope.hiddenNag = session.state.domainchangeClosed
      scope.closeNew = () ->
        scope.hiddenNag = session.state.domainchangeClosed = true
    else
      scope.url = null
