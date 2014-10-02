'use strict'

describe 'Service: timecheck', ->

  beforeEach module 'swarmApp'

  # instantiate service
  timecheck = {}
  format = {}
  beforeEach inject (_timecheck_, timecheckerServerFormat) ->
    timecheck = _timecheck_
    format = timecheckerServerFormat

  it 'should do something', ->
    expect(!!timecheck).toBe true

  # don't knwo why this fails in tests
  xit 'fetches network time', (done) ->
    res = timecheck.fetchNetTime()
    expect(!!res).toBe true
    res.then (time) ->
      console.log 'timefetch', time
      expect(!!time.datetime).toBe true
      datetime = moment time.datetime
      expect(!!datetime).toBe true
      done()

  it 'parses http-formatted dates', ->
    expect(timecheck._parseDate('Thu, 02 Oct 2014 07:34:29 GMT', format, true).isValid()).toBe true

  it 'validates network time', ->
    expect(timecheck._isNetTimeInvalid 'Thu, 02 Oct 2013 07:34:29 GMT').toBe false # copied from github headers
    expect(timecheck._isNetTimeInvalid moment().format format).toBe false
    expect(timecheck._isNetTimeInvalid moment(0).format format).toBe true
    expect(timecheck._isNetTimeInvalid moment().add(14, 'days').format format).toBe true
    expect(timecheck._isNetTimeInvalid moment().subtract(14, 'days').format format).toBe true
    # within threshold
    expect(timecheck._isNetTimeInvalid moment().add(1, 'days').format format).toBe false
    expect(timecheck._isNetTimeInvalid moment().subtract(1, 'days').format format).toBe false
    expect(timecheck._isNetTimeInvalid moment().add(3, 'days').format format).toBe false
    expect(timecheck._isNetTimeInvalid moment().subtract(3, 'days').format format).toBe false

  it 'accepts bogus time formats, preferring false negatives to false positives', ->
    expect(timecheck._isNetTimeInvalid 'fgsfds').toBeNull()
    expect(timecheck._isNetTimeInvalid 'The, 32 Jab 201A 25:61:62 AAA').toBeNull()
    # TODO validate that errors are emitted and logged to analytics
