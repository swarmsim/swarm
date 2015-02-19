'use strict'

describe 'Controller: ErrorsavingCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  ErrorsavingCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ErrorsavingCtrl = $controller 'ErrorsavingCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
