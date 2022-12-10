'use strict'

xdescribe 'Controller: DecimallegendCtrl', ->

  # load the controller's module
  beforeEach module 'swarmApp'

  DecimallegendCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DecimallegendCtrl = $controller 'DecimallegendCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
