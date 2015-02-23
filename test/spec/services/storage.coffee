'use strict'

describe 'Service: storage', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  storage = {}
  beforeEach inject (_storage_) ->
    storage = _storage_

  it 'should do something', ->
    expect(!!storage).toBe true
