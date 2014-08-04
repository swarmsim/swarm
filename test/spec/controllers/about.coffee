'use strict'

describe 'Controller: AboutCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  AboutCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    AboutCtrl = $controller 'AboutCtrl', {
      $scope: scope
    }

  xit 'should attach a session to the scope', ->
    expect(scope.session).not.toBeUndefined()
