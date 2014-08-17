'use strict'

describe 'Service: effecttypes', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  effecttypes = {}
  beforeEach inject (_effecttypes_) ->
    effecttypes = _effecttypes_

  it 'should do something', ->
    expect(!!effecttypes).toBe true
