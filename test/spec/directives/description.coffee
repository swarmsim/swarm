'use strict'

describe 'Directive: description', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}
  beforeEach inject ($controller, $rootScope, game) ->
    scope = $rootScope.$new()
    scope.game = game
    game.reset()

  afterEach inject (game) ->
    game.reset()

  it 'should render upgrade description with template text from spreadsheet (simple)', inject ($compile) ->
    scope.upgrade = upgrade = scope.game.upgrade 'hatchery'
    element = angular.element '<upgradedesc upgrade="upgrade"></upgradedesc>'
    element = $compile(element) scope
    undigested = element.text()
    scope.$digest()
    expect(element.text()).toBe 'Each hatchery produces 1 more larva per second. Currently, your hatcheries produce 1 larvae.'
    expect(element.text()).not.toBe undigested # prove the '1' really compiled, not hardcoded in spreadsheet

  it 'should render upgrade description with template text from spreadsheet', inject ($compile) ->
    scope.upgrade = upgrade = scope.game.upgrade 'clonelarvae'
    scope.game.now = scope.game.session.date.reified
    element = angular.element '<upgradedesc upgrade="upgrade"></upgradedesc>'
    element = $compile(element) scope
    #console.log element.text() # the template; {{template text}} from spreadsheet description
    # compiled element updates its {{expressions}} on digest
    scope.game.unit('larva')._setCount 665
    scope.game.unit('cocoon')._setCount 1
    scope.game.unit('invisiblehatchery')._setCount 1
    scope.$digest() # fills in {{expressions}} in element
    expect(element.text()).toBe 'Clone 666 new larvae.You produce 1 larvae per second, allowing you to clone up to 100,000 larvae. You have 666 larvae and cocoons available to clone.'
    # watch it update
    scope.game.unit('cocoon')._setCount 666001
    scope.$digest()
    expect(element.text()).toBe 'Clone 100,000 new larvae.You produce 1 larvae per second, allowing you to clone up to 100,000 larvae. You have 666,666 larvae and cocoons available to clone.'
