'use strict'

describe 'Controller: ErrorsavingCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  ErrorSavingCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ErrorSavingCtrl = $controller 'ErrorSavingCtrl', {
      $scope: scope
    }

  it 'exists', ->
    expect(!!scope).toBe true
