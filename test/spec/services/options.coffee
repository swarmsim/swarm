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

  it 'special-cases Swarmwarp velocity', ->
      options.velocityUnit 'warp'
      expect(options.velocityUnit().name).toBe 'warp'
      expect(options.velocityUnit().mult+'').toBe '900'
      expect(options.getVelocityUnit(unit:'drone').name).toBe 'warp'
      expect(options.getVelocityUnit(unit:'drone').mult+'').toBe '900'
      # energy is a special case: swarmwarp generates no energy
      expect(options.getVelocityUnit(unit:'energy').name).toBe 'sec'
      expect(options.getVelocityUnit(unit:'energy').mult+'').toBe '1'
