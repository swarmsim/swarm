'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:unit
 # @description
 # # unit
###
angular.module('swarmApp').directive 'unit', ($log, game, commands, options, $location, $sce) ->
  templateUrl: 'views/directive-unit.html'
  restrict: 'E'
  scope:
    cur: '='
  link: (scope, element, attrs) ->
    scope.game = game
    scope.commands = commands
    scope.options = options

    # not good enough - this runs only once, we want to be viewNewUpgrades()'ing constantly while the unit is in view
    #scope.cur.viewNewUpgrades()

    scope.form =
      mainBuynum: 1
    scope.mainBuynum = ->
      ret = Math.max 1, Math.floor scope.form.mainBuynum
      if _.isNaN ret
        ret = 1
      return ret
    scope.unitBuyTotal = (num) ->
      Math.min(num, scope.cur.maxCostMet()) * $scope.cur.stat 'twin', 1
    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

    scope.viewNewUpgrades = ->
      scope.cur.viewNewUpgrades()
      return undefined # important - the result is displayed

    scope.unitCostAsPercent = (unit, cost) ->
      MAX = 9999.99
      count = cost.unit.count()
      if count <= 0
        return MAX
      num = Math.max 1, unit.maxCostMet()
      Math.min MAX, cost.val * num / count

    scope.description = (resource, desc=resource.descriptionFn) ->
      # this makes descriptions a potential xss vector. careful to only use numbers.
      desc scope
