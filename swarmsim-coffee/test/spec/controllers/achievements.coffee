'use strict'

describe 'Controller: AchievementsCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  AchievementsCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    AchievementsCtrl = $controller 'AchievementsCtrl', {
      $scope: scope
    }

  it 'exists', ->
    expect(!!scope.game).toBe true
