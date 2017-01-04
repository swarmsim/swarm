'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'playfaboptions', (options) ->
  templateUrl: 'views/playfab/options.html'
  restrict: 'EA'
  link: (scope, element, attrs) ->
    scope.form =
      autopush: options.autopush()
    scope.name = 'foo'
    # scope.fetched = null
    scope.fetched = {encoded: 'abcde', date: moment(999)}

    scope.setAutopush = (val) -> options.autopush(val)
    scope.push = ->
    scope.fetch = ->
    scope.pull = ->
    scope.clear = ->
    scope.logout = ->
    scope.autopushError = ->
