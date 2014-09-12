'use strict'

describe 'Directive: tutorial', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  xit 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<tutorial></tutorial>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the tutorial directive'
