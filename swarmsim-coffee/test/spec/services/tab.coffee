'use strict'

describe 'Service: tab', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  Tab = {}
  beforeEach inject (_Tab_) ->
    Tab = _Tab_

  it 'should do something', ->
    expect(!!Tab).toBe true
