'use strict'

describe 'Controller: IframeCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  IframeCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    IframeCtrl = $controller 'IframeCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    #expect(scope.awesomeThings.length).toBe 3
