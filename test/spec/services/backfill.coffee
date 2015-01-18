'use strict'

describe 'Service: Backfill', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  Backfill = {}
  beforeEach inject (_Backfill_) ->
    Backfill = _Backfill_

  it 'should do something', ->
    expect(!!Backfill).toBe true
