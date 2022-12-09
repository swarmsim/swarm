/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import $ from 'jquery';

angular.module('swarmApp').directive('debugdd', (env, game, util) => ({
  scope: {
    label: '=',
    min: '=?',
    max: '=?',
    value: '='
  },

  restrict: 'E',

  template: `\
<dt ng-class="{envalert:value < min || value > max}">{{label}}</dt>
<dd ng-class="{envalert:value < min || value > max}">{{value|number}}</dt>\
`
}));

/**
 * @ngdoc directive
 * @name swarmApp.directive:debug
 * @description
 * # debug
*/
angular.module('swarmApp').directive('debug', (env, game, util, $location) => ({
  template: `\
<div ng-cloak ng-if="env.isDebugEnabled" class="container well">
  <p class="small pull-right">{{heights()}}</p>
  <p class="envalert">Debug</p>
  <div class="row">
    <div class="col-md-8">
      <div>
        Set count:
        <select tabindex="1" ng-options="u as u.type.label for u in game.resourcelist()" ng-model="form.resource" ng-change="selectResource()">
          <option value="">-- select unit --</option>
        </selected>
        <input tabindex="2" type="text" ng-model="form.count" ng-change="setResource()">
        <code>{{form.count|longnum}}</code>
        <button ng-click="game.save()">save</button>
      </div>
      <div>
        export <input tabindex="3" ng-model="form.export" onclick="this.select()">
        import <input tabindex="4" ng-model="form.import" ng-change="game.importSave(form.import);form.import=''">
        <button tabindex="5" class="resetalert" ng-click="confirmReset()">
          <span class="glyphicon glyphicon-warning-sign"></span>
          Wipe all saved data and start over
        </button>
      </div>
      <p>export age: {{now().getTime() - form.exportAge.getTime()}}</p>
      <div>
        Skip time:
        <button ng-click="game.skipTime(1, 'minute')">1 minute</button>
        <button ng-click="game.skipTime(5, 'minute')">5 minutes</button>
        <button ng-click="game.skipTime(15, 'minute')">15 minutes</button>
        <button ng-click="game.skipTime(1, 'hour')">1 hour</button>
        <button ng-click="game.skipTime(4, 'hour')">4 hour</button>
        <button ng-click="game.skipTime(8, 'hour')">8 hour</button>
        <button ng-click="game.skipTime(24, 'hour')">24 hour</button>
      </div>
      <div>
        Game speed: {{game.gameSpeed | number}}x
        <button ng-click="game.setGameSpeed(1)">1x: Normal</button>
        <button ng-click="game.setGameSpeed(0)">0x: Pause</button>
        <button ng-click="game.setGameSpeed(1.5)">1.5x</button>
        <button ng-click="game.setGameSpeed(2)">2x</button>
        <button ng-click="game.setGameSpeed(4)">4x</button>
        <button ng-click="game.setGameSpeed(10)">10x</button>
        <button ng-click="game.setGameSpeed(60)">60x</button>
        <button ng-click="game.setGameSpeed(100)">100x</button>
        <button ng-click="game.setGameSpeed(1000)">1000x</button>
        <button ng-click="game.setGameSpeed(3600)">3600x</button>
      </div>
      <p title="{{game.dateStarted().toString()}}">You started playing {{game.momentStarted().fromNow()}}<span ng-if="game.totalSkippedMillis() > 0"> (skipped an extra {{game.totalSkippedDuration().humanize()}})</span>.</p>
    </div>
    <dl class="dl-horizontal col-md-4">
      <debugdd label="'performance.memory.usedJSHeapSize'" value="mem()" max="100000000"></debugdd>
    </dl>
  </div>
</div>\
`,

  restrict: 'E',

  link(scope, element, attrs) {
    scope.env = env;
    scope.game = game;
    scope.util = util;

    scope.heights = () => ({
      'htmlheight()': $(document.documentElement).height(),
      'bodyheight()': $(document.body).height()
    });

    scope.form = {};
    scope.export = function() {
      scope.form.export = scope.game.session.exportSave();
      return scope.form.exportAge = new Date();
    };
    scope.now = () => scope.game.now;
    scope.export();

    scope.selectResource = () => scope.form.count = scope.form.resource.count();
    scope.setResource = function() {
      scope.game.withSave(function() {
        scope.form.resource._setCount(scope.form.count);
        // special case: nexus upgrades
        if (scope.form.resource.name === 'nexus') {
          return (() => {
            const result = [];
            for (var upgrade of Array.from(game.upgradelist())) {
              if (upgrade.name.substring(0,5) === 'nexus') {
                var level = parseInt(upgrade.name[5]);
                if (scope.form.count >= level) {
                  result.push(upgrade._setCount(1));
                } else {
                  result.push(undefined);
                }
              } else {
                result.push(undefined);
              }
            }
            return result;
          })();
        }
      });
      return scope.export();
    };

    scope.confirmReset = function() {
      if (confirm('really?')) {
        scope.game.reset(true);
        return $location.url('/');
      }
    };
    return scope.mem = () => __guard__(typeof performance !== 'undefined' && performance !== null ? performance.memory : undefined, x => x.usedJSHeapSize);
  }
}));

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}