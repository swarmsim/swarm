'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:buyunit
 # @description
 # # buyunit
###
angular.module('swarmApp').directive 'buyunit', ($log, game, commands) ->
  templateUrl: 'views/buyunit.html'
  scope:
    num: '=?'
    fixednum: '=?'
    unit: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.is25Visible = ->
      mcm25 = scope.resource.maxCostMet(0.25)
      return scope.resource.maxCostMet().greaterThan(mcm25) and mcm25.greaterThan(1)
    scope.fullnum = ->
      if scope.fixednum?
        fixednum = new Decimal(scope.fixednum).dividedBy(scope.unit.twinMult())
        return fixednum
      num = scope.num ? Decimal.ONE
      num = Decimal.max 1, Decimal.min scope.resource.maxCostMet(), new Decimal(num).floor()
      if num.isNaN()
        num = Decimal.ONE
      return num

    scope.unit = scope.resource = game.unit scope.unit
    $log.debug 'buyunit', scope.resource
    scope.buyResource = (args) ->
      args.unit = args.resource
      delete args.resource
      commands.buyUnit args
    scope.buyMaxResource = (args) ->
      args.unit = args.resource
      delete args.resource
      commands.buyMaxUnit args
    scope.statTwin = -> scope.resource.twinMult()
    scope.isBuyButtonVisible = -> scope.resource.isBuyButtonVisible()
    scope.verb = 'buy'

angular.module('swarmApp').directive 'buyupgrade', ($log, game, commands) ->
  templateUrl: 'views/buyunit.html'
  scope:
    num: '=?'
    upgrade: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.is25Visible = ->
      mcm25 = scope.resource.maxCostMet(0.25)
      return scope.resource.maxCostMet().greaterThan(mcm25) and mcm25.greaterThan(1)
    scope.fullnum = ->
      num = scope.num ? Decimal.ONE
      num = Decimal.max 1, Decimal.min scope.resource.maxCostMet(), new Decimal(num).floor()
      if num.isNaN()
        num = Decimal.ONE
      return num

    scope.upgrade = scope.resource = game.upgrade scope.upgrade
    $log.debug 'buyupgrade', scope.resource
    scope.buyResource = (args) ->
      args.upgrade = args.resource
      delete args.resource
      commands.buyUpgrade args
    scope.buyMaxResource = (args) ->
      args.upgrade = args.resource
      delete args.resource
      commands.buyMaxUpgrade args
    scope.statTwin = -> Decimal.ONE
    scope.isBuyButtonVisible = -> true
    scope.verb = if scope.upgrade.type.class == 'ability' then 'cast' else 'buy'

angular.module('swarmApp').directive 'buyunitdropdown', ($log, game, commands) ->
  templateUrl: 'views/buyunit-dropdown.html'
  scope:
    num: '=?'
    unit: '='
  restrict: 'E'
  transclude: true
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.is25Visible = (resource=scope.unit) ->
      mcm25 = resource.maxCostMet(0.25)
      return resource.maxCostMet().greaterThan(mcm25) and mcm25.greaterThan(1)
    scope.fullnum = ->
      num = scope.num ? Decimal.ONE
      num = Decimal.max 1, Decimal.min scope.unit.maxCostMet(), new Decimal(num).floor()
      if num.isNaN()
        num = Decimal.ONE
      return num
    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

    scope.click = ->
      scope.unit.viewNewUpgrades()

    scope.unit = game.unit scope.unit
    $log.debug 'buyunit', scope.unit
    scope.buyUnit = (args) ->
      commands.buyUnit args
    scope.buyMaxUnit = (args) ->
      commands.buyMaxUnit args
    scope.buyUpgrade = (args) ->
      commands.buyUpgrade args
    scope.buyMaxUpgrade = (args) ->
      commands.buyMaxUpgrade args
    scope.statTwin = -> scope.unit.twinMult()
    scope.isBuyButtonVisible = -> scope.unit.isBuyButtonVisible()
