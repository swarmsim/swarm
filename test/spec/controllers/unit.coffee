'use strict'

describe 'Controller: UnitCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  UnitCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    UnitCtrl = $controller 'UnitCtrl', {
      $scope: scope
    }

  it 'should attach a game to the scope', ->
    expect(!!scope.game).toBe true
