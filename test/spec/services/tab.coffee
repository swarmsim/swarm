'use strict'

describe 'Service: tab', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  tab = {}
  beforeEach inject (_tab_) ->
    tab = _tab_

  it 'should do something', ->
    expect(!!tab).toBe true
