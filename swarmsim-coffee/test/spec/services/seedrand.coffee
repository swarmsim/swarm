'use strict'

describe 'Service: seedrand', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  seedrand = {}
  beforeEach inject (_seedrand_) ->
    seedrand = _seedrand_

  it 'should do something', ->
    expect(!!seedrand).toBe true

  it 'generates deterministic random numbers', ->
    expect(seedrand.rand('x', 'y')).not.toEqual seedrand.rand('x', 'z')
    expect(seedrand.rand('x', 'y')).not.toEqual seedrand.rand('w', 'y')
    expect(seedrand.rand('x', 'y')).not.toEqual seedrand.rand('y', 'x')
    expect(seedrand.rand('x', 'y')).toEqual seedrand.rand('x', 'y')
    expect(seedrand.rand('x', 'y')).toEqual seedrand.rand('x', 'y')
    expect(seedrand.rand('x', 'y')).toEqual seedrand.rand('x', 'y')
