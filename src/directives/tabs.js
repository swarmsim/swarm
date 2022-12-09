/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:tabs
 * @description
 * # tabs
*/
angular.module('swarmApp').directive('tabs', (game, util, options, version, commands, hotkeys) => ({
  template: views.tabs,

  scope: {
    cur: '='
  },

  restrict: 'E',

  link(scope, element, attrs) {
    scope.tabs = game.tabs;
    scope.options = options;
    scope.game = game;

    scope.filterVisible = tab => tab.isVisible();

    scope.buyUpgrades = function(upgrades, costPercent) {
      // don't buy zero upgrades, it would invalidate undo. #628
      if (costPercent == null) { costPercent = 1; }
      if (upgrades.length > 0) {
        return commands.buyAllUpgrades({upgrades, percent:costPercent});
      }
    };

    util.animateController(scope, {game, options});

    scope.undo = function() {
      if (scope.isUndoable()) {
        return commands.undo();
      }
    };
    scope.secondsSinceLastAction = function() {
      let left;
      return (game.now.getTime() - ((left = __guardMethod__(commands._undo != null ? commands._undo.date : undefined, 'getTime', o => o.getTime())) != null ? left : 0)) / 1000;
    };
    scope.undoLimitSeconds = 30;
    scope.isRedo = () => commands._undo != null ? commands._undo.isRedo : undefined;
    scope.isUndoable = () => (scope.secondsSinceLastAction() < scope.undoLimitSeconds) && !scope.isRedo();

    scope.buyAllUpgrades = () => scope.buyUpgrades(game.availableAutobuyUpgrades());
    scope.buyCheapestUpgrades = () => scope.buyUpgrades(game.availableAutobuyUpgrades(0.25), 0.25);

    return hotkeys.bindTo(scope)
    .add({
      combo: 'z',
      description: 'Undo the last action',
      callback() { return scope.undo(); }}).add({
      combo: 'alt+a',
      description: 'Buy all available upgrades',
      callback() { return scope.buyAllUpgrades(); }}).add({
      combo: 'alt+c',
      description: 'Buy cheapest available upgrades',
      callback() { return scope.buyCheapestUpgrades(); }
    });
  }
}));
      

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}