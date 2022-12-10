'use strict'

describe 'Service: statistics', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  statistics = {}
  beforeEach inject (_statistics_) ->
    statistics = _statistics_

  it 'should do something', ->
    expect(!!statistics).toBe true
