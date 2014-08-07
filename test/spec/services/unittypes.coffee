'use strict'

describe 'Service: unittypes', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  unittypes = {}
  UnitTypes = {}
  UnitType = {}
  beforeEach inject (_unittypes_, _UnitTypes_, _UnitType_) ->
    unittypes = _unittypes_
    UnitTypes = _UnitTypes_
    UnitType = _UnitType_

  it 'should do something', ->
    expect(!!unittypes).toBe true
