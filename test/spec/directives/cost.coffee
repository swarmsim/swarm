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

  it 'should round small costs perfectly', inject ($compile) ->
    unit = game.unit 'drone'
    unit._setCount '888'
    scope.thecost = {unit:unit, val:new Decimal '1000'}

    element = angular.element '<cost num=1 costlist=""></cost>'
    element = $compile(element) scope
    remaining = element.isolateScope().showRemaining(scope.thecost)
    remaining = new Decimal remaining + ''
    # small costs are exact
    expect(unit.count().plus(remaining).minus(scope.thecost.val).isZero()).toBe true

  it 'should round large costs adequately, #257', inject ($compile) ->
    unit = game.unit 'drone'
    unit._setCount '0.888888888888888888888888888888888888888888888888888888888e50'
    scope.thecost = {unit:unit, val:new Decimal '1e50'}

    element = angular.element '<cost num=1 costlist=""></cost>'
    element = $compile(element) scope
    remaining = element.isolateScope().showRemaining(scope.thecost)
    remaining = new Decimal remaining + ''
    # pays the full cost, even if we have to round up a little for precision, but never pays less than the full cost
    expect(unit.count().plus(remaining).minus(scope.thecost.val).toNumber()).not.toBeLessThan 0
