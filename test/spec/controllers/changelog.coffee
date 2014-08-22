'use strict'

describe 'Controller: ChangelogCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  ChangelogCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ChangelogCtrl = $controller 'ChangelogCtrl', {
      $scope: scope
    }

  it 'should exist, but not really do much. All the work is in the view', ->
    expect(!!scope).toBe true
