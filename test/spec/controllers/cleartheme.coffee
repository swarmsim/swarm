'use strict'

describe 'Controller: ClearthemeCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  ClearthemeCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ClearthemeCtrl = $controller 'ClearthemeCtrl', {
      $scope: scope
    }

  it 'exists', ->
    expect(!!scope).toBe true
