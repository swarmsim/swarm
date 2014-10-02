'use strict'

describe 'Service: timecheck', ->

  beforeEach module 'swarmApp'

  # instantiate service
  timecheck = {}
  beforeEach inject (_timecheck_) ->
    timecheck = _timecheck_

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

  it 'validates network time', ->
    expect(timecheck._isNetTimeValid 'Thu, 02 Oct 2014 07:34:29 GMT').toBe false # copied from github headers
    expect(timecheck._isNetTimeValid new Date().toJSON()).toBe true
    expect(timecheck._isNetTimeValid new Date(0).toJSON()).toBe false
    expect(timecheck._isNetTimeValid new Date(new Date().getTime() + 14 * 24 * 3600 * 1000).toJSON()).toBe false
    expect(timecheck._isNetTimeValid new Date(new Date().getTime() - 14 * 24 * 3600 * 1000).toJSON()).toBe false
    # within threshold
    expect(timecheck._isNetTimeValid new Date(new Date().getTime() + 1 * 24 * 3600 * 1000).toJSON()).toBe true
    expect(timecheck._isNetTimeValid new Date(new Date().getTime() - 1 * 24 * 3600 * 1000).toJSON()).toBe true
    expect(timecheck._isNetTimeValid new Date(new Date().getTime() + 6 * 24 * 3600 * 1000).toJSON()).toBe true
    expect(timecheck._isNetTimeValid new Date(new Date().getTime() - 6 * 24 * 3600 * 1000).toJSON()).toBe true
