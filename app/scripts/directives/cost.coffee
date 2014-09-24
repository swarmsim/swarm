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
    buybuttons: '=?'
    noperiod: '=?'
  template: """
  <span ng-repeat="cost in costlist track by cost.unit.name">
    <span ng-if="!$first && $last"> and </span>
    <span ng-class="{costNotMet:!isCostMet(cost)}">
      {{totalCostVal(cost) | bignum}} {{spacer}}
      {{totalCostVal(cost) == 1 ? cost.unit.unittype.label : cost.unit.unittype.plural}}</span><span ng-if="$last && !noperiod">.</span><span ng-if="!$last && costlist.length > 2">, </span>
  </span>
  <span ng-if="buybuttons" ng-repeat="cost in costlist | filter:isRemainingBuyable track by cost.unit.name">
    <buyunit unit="cost.unit" fixednum="countRemaining(cost)"></buyunit>
  </span>
  """
  link: (scope, element, attrs) ->
    scope.num ?= 1
    scope.totalCostVal = (cost) ->
      cost.val * scope.num
    scope.isCostMet = (cost) ->
      cost.unit.count() >= scope.totalCostVal(cost)
    scope.countRemaining = (cost) ->
      return scope.totalCostVal(cost) - cost.unit.count()
    scope.isRemainingBuyable = (cost) ->
      remaining = scope.countRemaining cost
      # there is a cost remaining that we can't afford, but the remaining units are buyable. Can't necessarily afford them.
      return (remaining > 0 and cost.unit.isBuyable())
