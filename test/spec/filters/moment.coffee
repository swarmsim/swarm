'use strict'

describe 'Filter: moment', ->

  # load the filter's module
  beforeEach module 'swarmApp'

  # initialize a new instance of the filter before each test
  duration = {}
  warpDuration = {}
  options = {}
  beforeEach inject ($filter, _options_) ->
    duration = $filter 'duration'
    warpDuration = $filter 'warpDuration'
    options = _options_

  it 'should format short durations', ->
    template = 'd[d] h:mm:ss'
    expect(duration 123, 'minutes', template).toBe '2:03:00'
    expect(duration 900, 'seconds', template).toBe '15:00'
    expect(duration new Decimal(900), 'seconds', template).toBe '15:00'
    expect(duration 901, 'seconds', template).toBe '15:01'
    expect(duration 3599, 'seconds', template).toBe '59:59'
    expect(duration 123, 'hours', template).toBe '5d 3:00:00'
    expect(duration 123, 'days', template).toBe '123d 0:00:00'

  it 'should format full durations', ->
    options.durationFormat('full')
    expect(options.durationFormat()).toBe 'full'
    expect(duration 123, 'minutes').toBe '2:03:00'
    expect(duration 900, 'seconds').toBe '15:00'
    expect(duration new Decimal(900), 'seconds').toBe '15:00'
    expect(duration 901, 'seconds').toBe '15:01'
    expect(duration 3599, 'seconds').toBe '59:59'
    expect(duration 123, 'hours').toBe '5 day 03:00:00'
    expect(duration 123, 'days').toBe '4 mth 1 day 00:00:00'
    expect(duration 1234, 'days').toBe '3 yr 4 mth 17 day 00:00:00'

  it 'should format abbreviated durations', ->
    options.durationFormat('abbreviated')
    expect(options.durationFormat()).toBe 'abbreviated'
    expect(duration 123, 'minutes').toBe '2:03:00'
    expect(duration 900, 'seconds').toBe '15:00'
    expect(duration new Decimal(900), 'seconds').toBe '15:00'
    expect(duration 901, 'seconds').toBe '15:01'
    expect(duration 3599, 'seconds').toBe '59:59'
    expect(duration 123, 'hours').toBe '5 days 3 hours'
    expect(duration 123, 'days').toBe '4 months 1 days'
    expect(duration 1234, 'days').toBe '3 years 4 months'
    expect(duration 33, 'seconds').toBe '00:33'

  it 'should format human style durations', ->
    options.durationFormat('human')
    expect(options.durationFormat()).toBe 'human'
    expect(duration 123, 'minutes').toBe '2 hours'
    expect(duration 900, 'seconds').toBe '15 minutes'
    expect(duration new Decimal(900), 'seconds').toBe '15 minutes'
    expect(duration 901, 'seconds').toBe '15 minutes'
    expect(duration 3599, 'seconds').toBe 'an hour'
    expect(duration 123, 'hours').toBe '5 days'
    expect(duration 123, 'days').toBe '4 months'

  it 'should format warp durations', ->
    expect(warpDuration 123, 'minutes').toBe '2 hours and 3 minutes'
    expect(warpDuration 900, 'seconds').toBe '15 minutes'
    expect(warpDuration new Decimal(900), 'seconds').toBe '15 minutes'
    expect(warpDuration 901, 'seconds').toBe '15 minutes'
    expect(warpDuration 930, 'seconds').toBe '15 minutes'
    expect(warpDuration 3599, 'seconds').toBe '59 minutes'
    expect(warpDuration 123, 'hours').toBe '5 days 3 hours and 0 minutes'
    expect(warpDuration 123, 'days').toBe '123 days 0 hours and 0 minutes'
