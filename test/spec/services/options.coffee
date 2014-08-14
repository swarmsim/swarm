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
