'use strict'

describe 'Directive: cost', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}
  game = {}
  beforeEach inject ($controller, $rootScope, _game_) ->
    scope = $rootScope.$new()
    game = _game_

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<cost costlist="[]"></cost>'
    element = $compile(element) scope
    expect(element.text()).toBe ''
