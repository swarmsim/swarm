'use strict'

describe 'Directive: elm', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  xit 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<elm></elm>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the elm directive'
