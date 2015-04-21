'use strict'

xdescribe 'Directive: newslink', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  xit 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<newslink></newslink>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the newslink directive'
