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

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
