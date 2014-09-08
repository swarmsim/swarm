'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:cost
 # @description
 # # cost
###
angular.module('swarmApp').directive 'cost', ->
  restrict: 'AE'
  scope:
    costlist: '='
    num: '=?'
  template: """
  <span ng-repeat="cost in costlist" ng-init="totalcost=cost.val * num">
    <span ng-if="!$first && $last"> and </span>
    <span ng-class="{costNotMet:totalcost > cost.unit.count()}">
      {{totalcost | bignum}} {{spacer}}
      {{totalcost == 1 ? cost.unit.unittype.label : cost.unit.unittype.plural}}</span><span ng-if="$last">.</span><span ng-if="!$last && costlist.length > 2">, </span>
  </span>
  """
  link: (scope, element, attrs) ->
    scope.num ?= 1
