/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: StatisticsCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let StatisticsCtrl = {};
  let scope = {};
  let game = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope, _game_) {
    scope = $rootScope.$new();
    game = _game_;
    game.reset();
    return StatisticsCtrl = $controller('StatisticsCtrl', {
      $scope: scope
    });}));

  it('should attach statistics to the scope', function() {
    expect(!!scope).toBe(true);
    return expect(!!scope.statistics).toBe(true);
  });
  return it('should fetch stats', function() {
    expect(scope.unitStats(game.unit('drone'))).not.toBeNull();
    expect(scope.upgradeStats(game.upgrade('hatchery'))).not.toBeNull();
    game.unit('meat')._setCount(9999999);
    game.unit('drone').buy(1);
    game.upgrade('hatchery').buy(1);
    // dangit this doesn't work without $apply. fake it.
    scope.statistics.byUnit.drone = {elapsedFirst: 100};
    scope.statistics.byUpgrade.hatchery = {elapsedFirst: 100};
    expect(scope.unitStats(game.unit('drone'))).not.toBeNull();
    expect(scope.unitStats(game.unit('drone')).elapsedFirstStr).not.toBeNull();
    expect(scope.upgradeStats(game.upgrade('hatchery'))).not.toBeNull();
    return expect(scope.upgradeStats(game.upgrade('hatchery')).elapsedFirstStr).not.toBeNull();
  });
});
