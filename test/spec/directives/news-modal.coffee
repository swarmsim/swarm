'use strict'

describe 'Directive: newsModal', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<news-modal></news-modal>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the newsModal directive'
