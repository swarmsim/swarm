/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:AchievementsCtrl
 * @description
 * # AchievementsCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('AchievementsCtrl', function($scope, game, $location, $log) {
  $scope.game = game;
  if (game.session.state.achievementsShown == null) { game.session.state.achievementsShown = {
    earned: true,
    unearned: true,
    masked: true,
    order: 'default',
    reverse: false
  }; }
  $scope.form =
    {show: _.clone(game.session.state.achievementsShown)};

  const preds = {
    'default'(achievement) { return achievement.earnedAtMillisElapsed(); },
    percentComplete(achievement) { return achievement.progressOrder(); }
  };
  $scope.order =
    {pred: preds[$scope.form.show.order]};
  $scope.onChangeVisibility = function() {
    $scope.order.pred = preds[$scope.form.show.order];
    return game.withUnreifiedSave(() => game.session.state.achievementsShown = _.clone($scope.form.show));
  };

  $scope.state = function(achievement) {
    if (achievement.isEarned()) {
      return 'earned';
    }
    if (achievement.isUnmasked()) {
      return 'unearned';
    }
    // 'masked' zero-point vanity achievements aren't masked, but entirely hidden
    if (achievement.type.points <= 0) {
      return 'hidden';
    }
    return 'masked';
  };
  $scope.isVisible = function(achievement) {
    const state = $scope.state(achievement);
    if (state === 'earned') {
      return $scope.form.show.earned;
    } else if (state === 'unearned') {
      return $scope.form.show.unearned;
    } else {
      return $scope.form.show.masked;
    }
  };
  
  return $scope.achieveclick = function(achievement) {
    $log.debug('achieveclick', achievement);
    return $scope.$emit('achieveclick', achievement);
  };
});
