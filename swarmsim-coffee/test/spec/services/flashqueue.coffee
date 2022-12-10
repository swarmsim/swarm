'use strict'

describe 'Service: flashqueue', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  flashqueue = {}
  beforeEach inject (_flashqueue_) ->
    flashqueue = _flashqueue_

  it 'should do something', ->
    expect(!!flashqueue).toBe true
