'use strict'

describe 'Controller: LoginCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  LoginCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    LoginCtrl = $controller 'LoginCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
