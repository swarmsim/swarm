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

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
