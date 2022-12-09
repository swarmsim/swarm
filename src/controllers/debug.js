/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:DebugCtrl
 * @description
 * # DebugCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('DebugCtrl', function($scope, session, game, spreadsheet, env, unittypes, flashqueue, $timeout, $log, util) {
  $scope.$emit('debugPage');

  if (!env.isDebugEnabled) {
    return;
  }

  $scope.dumps = [
    {title:'env', data:env},
    {title:'game', data:!!game},
    {title:'session', data:session},
    {title:'unittypes', data:!!unittypes},
    {title:'spreadsheet', data:spreadsheet}
    ];

  $scope.notify = flashqueue;
  $scope.achieve = () => $scope.notify.push({type:{label:'fake achievement',longdesc:'yay'}, pointsEarned() { return 42; }, description() { return 'wee'; }});

  $scope.throwUp = function() {
    throw new Error("throwing up (test exception)");
  };
  $scope.assertFail = () => util.assert(false, "throwing up (test assertion failure)");
  $scope.error = () => util.error("throwing up (test util.error)");
  $scope.form = {};
  $scope.session = session;
  $scope.$watch('form.session', function(text, text0) {
    if (text !== text0) {
      $log.debug('formsession update', text, $scope.session._saves(text, false));
      return $scope.session.importSave($scope.session._saves(JSON.parse(text), false));
    } else {
      return $log.debug('formsession equal');
    }
  });
  $scope.$watch('session', (function() {
    $log.debug('session update');
    $scope.form.sessionExport = $scope.session.exportSave();
    return $scope.form.session = JSON.stringify($scope.session._loads($scope.form.sessionExport), undefined, 2);
  })()
  );
  $scope.game = game;
  $scope.env = env;
  return $scope.confirmReset = function() {
    if (confirm('You will lose everything and restart the game. You sure?')) {
      return game.reset();
    }
  };
});
