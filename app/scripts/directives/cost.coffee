'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:cost
 # @description
 # # cost
###
angular.module('swarmApp').directive 'cost', ($log) ->
  restrict: 'E'
  scope:
    costlist: '='
    num: '=?'
    noperiod: '=?'
  template: """
  <span ng-repeat="cost in costlist track by cost.unit.name">
    <span ng-if="!$first && $last"> and </span>
    <span ng-class="{costNotMet:cost.val*num> cost.unit.count()}">
      {{cost.val*num| bignum}} {{spacer}}
      {{cost.val*num == 1 ? cost.unit.unittype.label : cost.unit.unittype.plural}}</span><span ng-if="$last && !noperiod">.</span><span ng-if="!$last && costlist.length > 2">, </span>
  </span>
  """
  link: (scope, element, attrs) ->
    scope.num ?= 1
