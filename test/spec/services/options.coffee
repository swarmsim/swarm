'use strict'

describe 'Service: options', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  options = {}
  beforeEach inject (_options_) ->
    options = _options_

  it 'should do something', ->
    expect(!!options).toBe true

  it 'sets velocity', ->
    expect(options.VELOCITY_UNITS.list.length).toBeGreaterThan 0
    for vu in options.VELOCITY_UNITS.list
      options.velocityUnit vu.name
      expect(options.velocityUnit().name).toBe vu.name
