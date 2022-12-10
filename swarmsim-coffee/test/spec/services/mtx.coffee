'use strict'

describe 'Service: mtx', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  mtx = {}
  beforeEach inject (_mtx_) ->
    mtx = _mtx_

  it 'should do something', ->
    expect(!!mtx).toBe true
