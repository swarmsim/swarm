'use strict'

describe 'Directive: description', ->

  # load the directive's module
  beforeEach module 'swarmApp'

  scope = {}
  beforeEach inject ($controller, $rootScope, game) ->
    scope = $rootScope.$new()
    scope.game = game

  it 'should render upgrade description with template text from spreadsheet', inject ($compile) ->
    scope.upgrade = upgrade = scope.game.upgrade 'injectlarvae'
    scope.game.unit('invisiblehatchery')._setCount 0 # no velocity plz
    element = angular.element '<upgradedesc upgrade="upgrade"></upgradedesc>'
    element = $compile(element) scope
    #console.log element.text() # the template; {{template text}} from spreadsheet description
    # compiled element updates its {{expressions}} on digest
    scope.game.unit('larva')._setCount 665
    scope.game.unit('cocoon')._setCount 1
    scope.$digest() # fills in {{expressions}} in element
    expect(element.text()).toBe 'Use meat to instantly create 1,000 larvae and clone your existing 666 larvae and cocoons.'
    # watch it update
    scope.game.unit('cocoon')._setCount 666001
    scope.$digest()
    expect(element.text()).toBe 'Use meat to instantly create 1,000 larvae and clone your existing 667 thousand larvae and cocoons.'
