'use strict'

describe 'Controller: FlashqueueCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  FlashQueueCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    FlashQueueCtrl = $controller 'FlashQueueCtrl', {
      $scope: scope
    }

  it 'should exist', ->
    expect(!!scope.achieveQueue).toBe true
