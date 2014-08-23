'use strict'

describe 'Controller: StatisticsCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  StatisticsCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    StatisticsCtrl = $controller 'StatisticsCtrl', {
      $scope: scope
    }

  it 'should attach statistics to the scope', ->
    expect(!!scope).toBe true
    expect(!!scope.stats).toBe true
