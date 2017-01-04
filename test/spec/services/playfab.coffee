'use strict'

describe 'Service: playfab', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  playfab = {}
  beforeEach inject (_playfab_) ->
    playfab = _playfab_

  it 'should do something', ->
    expect(!!playfab).toBe true
