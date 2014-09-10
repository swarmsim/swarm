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

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
