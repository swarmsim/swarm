'use strict'

describe 'Service: units', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  units = {}
  beforeEach inject (_units_) ->
    units = _units_

  it 'should do something', ->
    expect(!!units).toBe true
