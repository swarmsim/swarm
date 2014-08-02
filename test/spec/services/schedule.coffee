'use strict'

describe 'Service: schedule', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  schedule = {}
  beforeEach inject (_schedule_) ->
    schedule = _schedule_

  it 'should do something', ->
    expect(!!schedule).toBe true
