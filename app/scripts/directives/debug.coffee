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
        <div>
          Game speed: {{game.gameSpeed | number}}x
          <button ng-click="game.setGameSpeed(1)">1x: Normal</button>
          <button ng-click="game.setGameSpeed(0)">0x: Pause</button>
          <button ng-click="game.setGameSpeed(1.5)">1.5x</button>
          <button ng-click="game.setGameSpeed(2)">2x</button>
          <button ng-click="game.setGameSpeed(4)">4x</button>
          <button ng-click="game.setGameSpeed(10)">10x</button>
          <button ng-click="game.setGameSpeed(20)">20x</button>
          <button ng-click="game.setGameSpeed(50)">50x</button>
          <button ng-click="game.setGameSpeed(100)">100x</button>
          <button ng-click="game.setGameSpeed(1000)">1000x</button>
        </div>
        <p title="{{game.dateStarted().toString()}}">You started playing {{game.momentStarted().fromNow()}}<span ng-if="game.totalSkippedMillis() > 0"> (skipped an extra {{game.totalSkippedDuration().humanize()}})</span>.</p>
      </div>
    </div>
    """
    restrict: 'E'
    link: (scope, element, attrs) ->
      scope.env = env
      scope.game = game
