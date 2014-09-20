'use strict'

describe 'Controller: LoadsaveCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  LoadSaveCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    LoadSaveCtrl = $controller 'LoadSaveCtrl', {
      $scope: scope
    }

  it 'should exist', ->
    expect(!!scope).toBe true
