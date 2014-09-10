'use strict'

describe 'Directive: buyunit', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<buyunit></buyunit>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the buyunit directive'
