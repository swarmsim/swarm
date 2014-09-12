'use strict'

describe 'Controller: Main2Ctrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  Main2Ctrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    Main2Ctrl = $controller 'Main2Ctrl', {
      $scope: scope
    }

  it 'should attach a game to the scope', ->
    expect(!!scope.game).toBe true
