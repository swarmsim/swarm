'use strict'

describe 'Controller: DebugCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  DebugCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DebugCtrl = $controller 'DebugCtrl', {
      $scope: scope
    }

  it 'should attach a session to the scope', ->
    expect(scope.session).not.toBeUndefined()
