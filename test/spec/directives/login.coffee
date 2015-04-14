'use strict'

describe 'Directive: login', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<login></login>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the login directive'
