'use strict'

describe 'Filter: moment', ->

  # load the filter's module
  beforeEach module 'swarmApp'

  # initialize a new instance of the filter before each test
  duration = {}
  warpDuration = {}
  beforeEach inject ($filter) ->
    duration = $filter 'duration'
    warpDuration = $filter 'warpDuration'

  it 'should format short durations', ->
    expect(duration 123, 'minutes').toBe '2:03:00'
    expect(duration 900, 'seconds').toBe '15:00'
    expect(duration new Decimal(900), 'seconds').toBe '15:00'
    expect(duration 901, 'seconds').toBe '15:01'
    expect(duration 3599, 'seconds').toBe '59:59'
    expect(duration 123, 'hours').toBe '5d 3:00:00'
    expect(duration 123, 'days').toBe '123d 0:00:00'

  it 'should format warp durations', ->
    expect(warpDuration 123, 'minutes').toBe '2 hours and 3 minutes'
    expect(warpDuration 900, 'seconds').toBe '15 minutes'
    expect(warpDuration new Decimal(900), 'seconds').toBe '15 minutes'
    expect(warpDuration 901, 'seconds').toBe '15 minutes'
    expect(warpDuration 930, 'seconds').toBe '15 minutes'
    expect(warpDuration 3599, 'seconds').toBe '59 minutes'
    expect(warpDuration 123, 'hours').toBe '5 days 3 hours and 0 minutes'
    expect(warpDuration 123, 'days').toBe '123 days 0 hours and 0 minutes'
