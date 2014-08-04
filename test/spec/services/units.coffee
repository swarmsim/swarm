'use strict'

describe 'Service: units', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  units = {}
  Units = {}
  Unit = {}
  beforeEach inject (_units_, _Units_, _Unit_) ->
    units = _units_
    Units = _Units_
    Unit = _Unit_

  it 'should do something', ->
    expect(!!units).toBe true
