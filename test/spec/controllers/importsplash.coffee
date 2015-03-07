'use strict'

describe 'Controller: ImportsplashCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  ImportsplashCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ImportsplashCtrl = $controller 'ImportsplashCtrl', {
      $scope: scope
    }

  xit 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
