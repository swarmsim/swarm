'use strict'
import {Decimal} from '@bower_components/decimal.js'

###*
 # @ngdoc directive
 # @name swarmApp.directive:buyunitInput
 # @description
 # # buyunitInput
###
angular.module('swarmApp').directive 'buyunitInput', ($log, commands, options, $location, parseNumber) ->
  templateUrl: 'views/buyunit-input.html'
  restrict: 'E'
  scope:
    unit: '='
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.options = options

    scope.form = {buyCount:''}
    search = $location.search()
    if search.num?
      scope.form.buyCount = search.num
    else if search.twinnum?
      # legacy format - our code doesn't use `?twinnum=n` anymore, but it used to. some users might still use it.
      scope.form.buyCount = "=#{search.twinnum}"

    _buyCount = new Decimal(1)
    scope.buyCount = ->
      parsed = parseNumber(scope.form.buyCount or '1', scope.unit) ? new Decimal(1)
      # caching required for angular
      if not parsed.equals _buyCount
        _buyCount = parsed
      return _buyCount

    scope.unitCostAsPercent = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.count()
      if count.lessThanOrEqualTo 0
        return MAX
      num = Decimal.max 1, unit.maxCostMet()
      Decimal.min MAX, cost.val.times(num).dividedBy(count)
    
    scope.unitCostAsPercentOfVelocity = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.velocity()
      if count.lessThanOrEqualTo 0
        return MAX
      Decimal.min MAX, cost.val.times(unit.maxCostMetOfVelocity()).dividedBy(count)
