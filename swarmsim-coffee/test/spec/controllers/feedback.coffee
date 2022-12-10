'use strict'

describe 'Controller: FeedbackCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  FeedbackCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    FeedbackCtrl = $controller 'FeedbackCtrl', {
      $scope: scope
    }

  xit 'exists', ->
    expect(!!scope).toBe true
