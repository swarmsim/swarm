'use strict'

describe 'Service: Kongregate', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  Kongregate = {}
  beforeEach inject (_Kongregate_) ->
    Kongregate = _Kongregate_

  it 'should do something', ->
    expect(!!Kongregate).toBe true
