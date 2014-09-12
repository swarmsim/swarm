'use strict'

describe 'Directive: buyunit', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}
  game = {}

  beforeEach inject ($controller, $rootScope, _game_) ->
    scope = $rootScope.$new()
    game = _game_

  # TODO ugh this isn't working at all
  xit 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<buyunit unit="cur"></buyunit>'
    scope.cur = game.unit 'drone'
    element = $compile(element)(scope)
    expect(element.html()).not.toBe ''
