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

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
