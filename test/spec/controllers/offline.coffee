'use strict'

describe 'Controller: OfflineCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  OfflineCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    OfflineCtrl = $controller 'OfflineCtrl', {
      $scope: scope
    }

  it 'should exist', ->
    expect(!!scope).toBe true
    expect(scope.achieved?).toBe true
