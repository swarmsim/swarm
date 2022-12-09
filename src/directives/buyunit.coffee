'use strict'
import _ from 'lodash'
import {Decimal} from 'decimal.js'
import * as views from '../views'

###*
 # @ngdoc directive
 # @name swarmApp.directive:buyunit
 # @description
 # # buyunit
###
angular.module('swarmApp').directive 'buyunit', ($log, game, commands, hotkeys) ->
  template: views.buyunit
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
        fixednum = new Decimal(scope.fixednum+'').dividedBy(scope.unit.twinMult())
        return fixednum
      num = scope.num ? 1
      num = Decimal.max 1, Decimal.min scope.resource.maxCostMet(), new Decimal(num+'').floor()
      if num.isNaN()
        num = new Decimal(1)
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
    scope.verb = scope.unit?.type?.verb ? 'buy'

    # This assumes there's only one buyunit on the screen at a time - currently true
    hotkeys.bindTo(scope)
    .add
      combo:'alt+b'
      description: _.capitalize(scope.verb)+' '+scope.resource.type.plural
      callback: () ->
        if scope.resource.isCostMet()
          scope.buyResource {resource: scope.resource, num: scope.fullnum()}
    #.add
    #  combo:'ctrl+alt+b'
    #  description: _.capitalize(scope.verb)+' 25% '+scope.resource.type.plural,
    #  callback: () ->
    #    if scope.is25Visible()
    #      scope.buyMaxResource {resource: scope.resource, percent: 0.25}
    .add
      combo:'shift+alt+b'
      description: _.capitalize(scope.verb)+' max '+scope.resource.type.plural,
      callback: () ->
        if scope.resource.maxCostMet().greaterThan(1)
          scope.buyMaxResource {resource: scope.resource, percent: 1}


angular.module('swarmApp').directive 'buyupgrade', ($log, game, commands, hotkeys) ->
  template: views.buyunit
  scope:
    num: '=?'
    upgrade: '='
    index: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.is25Visible = ->
      mcm25 = scope.resource.maxCostMet(0.25)
      return scope.resource.maxCostMet().greaterThan(mcm25) and mcm25.greaterThan(1)
    scope.fullnum = ->
      num = scope.num ? 1
      num = Decimal.max 1, Decimal.min scope.resource.maxCostMet(), new Decimal(num+'').floor()
      if num.isNaN()
        num = new Decimal(1)
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
    scope.statTwin = -> new Decimal(1)
    scope.isBuyButtonVisible = -> true
    scope.verb = if scope.upgrade.type.class == 'ability' then 'cast' else 'buy'

    keys = '1234567890-='
    if scope.index?
      console.log('bind upgrade key', scope.index)
      key = keys[scope.index]
      hotkeys.bindTo(scope)
      .add
        combo:'alt+shift+'+key
        description: _.capitalize(scope.verb)+' '+scope.resource.type.label
        callback: (event) ->
          if scope.resource.isCostMet()
            scope.buyResource {resource: scope.resource, num: scope.fullnum()}

angular.module('swarmApp').directive 'buyunitdropdown', ($log, game, commands) ->
  template: views.buyunitDropdown
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
      num = scope.num ? 1
      num = Decimal.max 1, Decimal.min scope.unit.maxCostMet(), new Decimal(num+'').floor()
      if num.isNaN()
        num = new Decimal(1)
      return num
    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

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
