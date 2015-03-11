'use strict'

describe 'Service: remotesave', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  remotesave = {}
  beforeEach inject (_remotesave_) ->
    remotesave = _remotesave_

  xit 'should do something', ->
    expect(!!remotesave).toBe true
