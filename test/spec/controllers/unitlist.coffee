'use strict'

describe 'Controller: UnitlistCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  UnitlistCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    UnitlistCtrl = $controller 'UnitlistCtrl', {
      $scope: scope
    }

  it 'should attach a session to the scope', ->
    expect(scope.session).not.toBeUndefined()
