'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:description
 # @description
 #
 # Use either static descriptions from the spreadsheet, or templated descriptions in /app/views/desc.
 # Spreadsheet descriptions of '' or '-' indicate that we should try to use a template.
 # (We used to do stupid $compile tricks to allow templating in the spreadsheet, but that caused memory leaks. #177)
###
angular.module('swarmApp').directive 'unitdesc', (game) ->
  template: '<p ng-if="templateUrl" ng-include="templateUrl"></p><p ng-if="!templateUrl">{{desc}}</p>'
  scope:
    unit: '='
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.game ?= game
    scope.desc = scope.unit.unittype.description
    scope.templateUrl = do ->
      if scope.desc == '-' or not scope.desc
        return "views/desc/unit/#{scope.unit.name}.html"
      return ''

angular.module('swarmApp').directive 'upgradedesc', (game) ->
  template: '<p ng-if="templateUrl" ng-include="templateUrl"></p><p ng-if="!templateUrl">{{desc}}</p>'
  scope:
    upgrade: '='
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.game ?= game
    scope.desc = scope.upgrade.type.description
    scope.templateUrl = do ->
      if scope.desc == '-' or not scope.desc
        return "views/desc/upgrade/#{scope.upgrade.name}.html"
      return ''
