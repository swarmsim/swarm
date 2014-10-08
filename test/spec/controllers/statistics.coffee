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
    StatisticsCtrl = $controller 'StatisticsCtrl', {
      $scope: scope
    }

  it 'should attach statistics to the scope', ->
    expect(!!scope).toBe true
    expect(!!scope.statistics).toBe true
  it 'should fetch stats', ->
    expect(scope.unitStats game.unit 'drone').not.toBeNull()
    expect(scope.upgradeStats game.upgrade 'hatchery').not.toBeNull()
