'use strict'

describe 'Filter: moment', ->

  # load the filter's module
  beforeEach module 'swarmApp'

  # initialize a new instance of the filter before each test
  duration = {}
  options = {}
  toLocaleString = Number.prototype.toLocaleString
  beforeEach inject ($filter, _options_) ->
    duration = $filter 'duration'
    options = _options_
    # hack to make phantomJS work
    # https://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
    Number.prototype.toLocaleString = ->
      return this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

  afterEach ->
    Number.prototype.toLocaleString = toLocaleString

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
    options.notation('standard-decimal')
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
    expect(duration 1000, 'years').toBe '1,000 years'
    expect(duration 1000000, 'years').toBe '1.00000 million years'
    expect(duration 1e21, 'years').toBe '1.00000 sextillion years'
    options.notation('scientific-e')
    expect(duration 1000000, 'years').toBe '1.00000e6 years'
    expect(duration 1e21, 'years').toBe '1.00000e21 years'

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
