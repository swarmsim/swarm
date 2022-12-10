'use strict'

describe 'Controller: OptionsCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  OptionsCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    OptionsCtrl = $controller 'OptionsCtrl', {
      $scope: scope
    }

  it 'should attach options to the scope', ->
    expect(!!scope.options).toBe true
