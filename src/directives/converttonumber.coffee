'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:converttonumber
 # @description
 # # converttonumber

 # http://code.angularjs.org/1.4.7/docs/api/ng/directive/select
 # http://stackoverflow.com/questions/28114970/angularjs-ng-options-using-number-for-model-does-not-select-initial-value
 # it used to work this way by default
###
angular.module('swarmApp').directive 'convertToNumber', ->
  require: 'ngModel'
  link: (scope, element, attrs, ngModel) ->
    ngModel.$parsers.push (val) ->
      return parseInt val, 10
    ngModel.$formatters.push (val) ->
      return "#{val}"
