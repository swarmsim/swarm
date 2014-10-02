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
    scope.floor = (val) -> Math.floor val

    # not good enough - this runs only once, we want to be viewNewUpgrades()'ing constantly while the unit is in view
    #scope.cur.viewNewUpgrades()

    parseNum = (num) ->
      if num?
        num = Number num
        if (_.isNumber num) and (not _.isNaN num) and num > 0
          return num
      return undefined
    scope.form =
      mainBuynum: do ->
        if (search = $location.search())?
          if (ret = parseNum search.num)?
            return Math.ceil ret
          if (ret = parseNum search.twinnum)?
            ret /= scope.cur.twinMult()
            return Math.ceil ret
        return 1
    scope.mainBuynum = ->
      ret = Math.max 1, Math.floor Number scope.form.mainBuynum
      if _.isNaN ret
        ret = 1
      return ret
    scope.unitBuyTotal = (num) ->
      Math.min(num, scope.cur.maxCostMet()) * $scope.cur.twinMult()
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
