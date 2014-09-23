'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:debug
 # @description
 # # debug
###
angular.module('swarmApp').directive 'debug', (env, game) ->
    template: """
    <div ng-if="env.isDebugEnabled" class="container well">
      <p class="envalert">Debug</p>
      <div>
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
        <p title="{{game.dateStarted().toString()}}">You started playing {{game.momentStarted().fromNow()}}<span ng-if="game.totalSkippedMillis() > 0"> (skipped an extra {{game.totalSkippedDuration().humanize()}}</span>.</p>
      </div>
    </div>
    """
    restrict: 'E'
    link: (scope, element, attrs) ->
      scope.env = env
      scope.game = game
