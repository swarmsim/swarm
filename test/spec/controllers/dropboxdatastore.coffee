'use strict'

describe 'Controller: DropboxdatastoreCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  DropboxdatastoreCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DropboxdatastoreCtrl = $controller 'DropboxdatastoreCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
