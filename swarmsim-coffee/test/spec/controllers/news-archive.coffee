'use strict'

xdescribe 'Controller: NewsArchiveCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  NewsArchiveCtrl = {}

  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    NewsArchiveCtrl = $controller 'NewsArchiveCtrl', {
      # place here mocked dependencies
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(NewsArchiveCtrl.awesomeThings.length).toBe 3
