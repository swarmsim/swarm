/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';
import {Decimal} from 'decimal.js';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:buyunit
 * @description
 * # buyunit
*/
angular.module('swarmApp').directive('buyunit', ($log, game, commands, hotkeys) => ({
  template: views.buyunit,

  scope: {
    num: '=?',
    fixednum: '=?',
    unit: '='
  },

  restrict: 'E',

  link(scope, element, attrs) {
    scope.commands = commands;
    scope.is25Visible = function() {
      const mcm25 = scope.resource.maxCostMet(0.25);
      return scope.resource.maxCostMet().greaterThan(mcm25) && mcm25.greaterThan(1);
    };
    scope.fullnum = function() {
      if (scope.fixednum != null) {
        const fixednum = new Decimal(scope.fixednum+'').dividedBy(scope.unit.twinMult());
        return fixednum;
      }
      let num = scope.num != null ? scope.num : 1;
      num = Decimal.max(1, Decimal.min(scope.resource.maxCostMet(), new Decimal(num+'').floor()));
      if (num.isNaN()) {
        num = new Decimal(1);
      }
      return num;
    };

    scope.unit = (scope.resource = game.unit(scope.unit));
    $log.debug('buyunit', scope.resource);
    scope.buyResource = function(args) {
      args.unit = args.resource;
      delete args.resource;
      return commands.buyUnit(args);
    };
    scope.buyMaxResource = function(args) {
      args.unit = args.resource;
      delete args.resource;
      return commands.buyMaxUnit(args);
    };
    scope.statTwin = () => scope.resource.twinMult();
    scope.isBuyButtonVisible = () => scope.resource.isBuyButtonVisible();
    scope.verb = __guard__(scope.unit != null ? scope.unit.type : undefined, x => x.verb) != null ? __guard__(scope.unit != null ? scope.unit.type : undefined, x => x.verb) : 'buy';

    // This assumes there's only one buyunit on the screen at a time - currently true
    return hotkeys.bindTo(scope)
    .add({
      combo:'alt+b',
      description: _.capitalize(scope.verb)+' '+scope.resource.type.plural,
      callback() {
        if (scope.resource.isCostMet()) {
          return scope.buyResource({resource: scope.resource, num: scope.fullnum()});
        }
      }})
    //.add
    //  combo:'ctrl+alt+b'
    //  description: _.capitalize(scope.verb)+' 25% '+scope.resource.type.plural,
    //  callback: () ->
    //    if scope.is25Visible()
    //      scope.buyMaxResource {resource: scope.resource, percent: 0.25}
    .add({
      combo:'shift+alt+b',
      description: _.capitalize(scope.verb)+' max '+scope.resource.type.plural,
      callback() {
        if (scope.resource.maxCostMet().greaterThan(1)) {
          return scope.buyMaxResource({resource: scope.resource, percent: 1});
        }
      }});
  }
}));


angular.module('swarmApp').directive('buyupgrade', ($log, game, commands, hotkeys) => ({
  template: views.buyunit,

  scope: {
    num: '=?',
    upgrade: '=',
    index: '=?'
  },

  restrict: 'E',

  link(scope, element, attrs) {
    scope.commands = commands;
    scope.is25Visible = function() {
      const mcm25 = scope.resource.maxCostMet(0.25);
      return scope.resource.maxCostMet().greaterThan(mcm25) && mcm25.greaterThan(1);
    };
    scope.fullnum = function() {
      let num = scope.num != null ? scope.num : 1;
      num = Decimal.max(1, Decimal.min(scope.resource.maxCostMet(), new Decimal(num+'').floor()));
      if (num.isNaN()) {
        num = new Decimal(1);
      }
      return num;
    };

    scope.upgrade = (scope.resource = game.upgrade(scope.upgrade));
    $log.debug('buyupgrade', scope.resource);
    scope.buyResource = function(args) {
      args.upgrade = args.resource;
      delete args.resource;
      return commands.buyUpgrade(args);
    };
    scope.buyMaxResource = function(args) {
      args.upgrade = args.resource;
      delete args.resource;
      return commands.buyMaxUpgrade(args);
    };
    scope.statTwin = () => new Decimal(1);
    scope.isBuyButtonVisible = () => true;
    scope.verb = scope.upgrade.type.class === 'ability' ? 'cast' : 'buy';

    const keys = '1234567890-=';
    if (scope.index != null) {
      console.log('bind upgrade key', scope.index);
      const key = keys[scope.index];
      return hotkeys.bindTo(scope)
      .add({
        combo:'alt+shift+'+key,
        description: _.capitalize(scope.verb)+' '+scope.resource.type.label,
        callback(event) {
          if (scope.resource.isCostMet()) {
            return scope.buyResource({resource: scope.resource, num: scope.fullnum()});
          }
        }});
    }
  }
}));

angular.module('swarmApp').directive('buyunitdropdown', ($log, game, commands) => ({
  template: views.buyunitDropdown,

  scope: {
    num: '=?',
    unit: '='
  },

  restrict: 'E',
  transclude: true,

  link(scope, element, attrs) {
    scope.commands = commands;
    scope.is25Visible = function(resource) {
      if (resource == null) { resource = scope.unit; }
      const mcm25 = resource.maxCostMet(0.25);
      return resource.maxCostMet().greaterThan(mcm25) && mcm25.greaterThan(1);
    };
    scope.fullnum = function() {
      let num = scope.num != null ? scope.num : 1;
      num = Decimal.max(1, Decimal.min(scope.unit.maxCostMet(), new Decimal(num+'').floor()));
      if (num.isNaN()) {
        num = new Decimal(1);
      }
      return num;
    };
    scope.filterVisible = upgrade => upgrade.isVisible();

    scope.unit = game.unit(scope.unit);
    $log.debug('buyunit', scope.unit);
    scope.buyUnit = args => commands.buyUnit(args);
    scope.buyMaxUnit = args => commands.buyMaxUnit(args);
    scope.buyUpgrade = args => commands.buyUpgrade(args);
    scope.buyMaxUpgrade = args => commands.buyMaxUpgrade(args);
    scope.statTwin = () => scope.unit.twinMult();
    return scope.isBuyButtonVisible = () => scope.unit.isBuyButtonVisible();
  }
}));

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}