'use strict'

describe 'Controller: StatisticsCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  StatisticsCtrl = {}
  scope = {}
  game = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope, _game_) ->
    scope = $rootScope.$new()
    game = _game_
    game.reset()
    StatisticsCtrl = $controller 'StatisticsCtrl', {
      $scope: scope
    }

  it 'should attach statistics to the scope', ->
    expect(!!scope).toBe true
    expect(!!scope.statistics).toBe true
  it 'should fetch stats', ->
    expect(scope.unitStats game.unit 'drone').not.toBeNull()
    expect(scope.upgradeStats game.upgrade 'hatchery').not.toBeNull()
    game.unit('meat')._setCount 9999999
    game.unit('drone').buy 1
    game.upgrade('hatchery').buy 1
    # dangit this doesn't work without $apply. fake it.
    scope.statistics.byUnit.drone = {elapsedFirst: 100}
    scope.statistics.byUpgrade.hatchery = {elapsedFirst: 100}
    expect(scope.unitStats game.unit 'drone').not.toBeNull()
    expect(scope.unitStats(game.unit 'drone').elapsedFirstStr).not.toBeNull()
    expect(scope.upgradeStats game.upgrade 'hatchery').not.toBeNull()
    expect(scope.upgradeStats(game.upgrade 'hatchery').elapsedFirstStr).not.toBeNull()
