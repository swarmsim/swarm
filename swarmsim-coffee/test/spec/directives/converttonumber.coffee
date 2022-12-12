'use strict'

describe 'Directive: converttonumber', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  xit 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<converttonumber></converttonumber>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the converttonumber directive'
