'use strict'

describe 'Service: feedback', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  feedback = {}
  beforeEach inject (_feedback_) ->
    feedback = _feedback_

  it 'should do something', ->
    expect(!!feedback).toBe true
