'use strict'

describe 'Service: session', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  session = {}
  beforeEach inject (_session_) ->
    session = _session_

  it 'should do something', ->
    expect(!!session).toBe true

  it 'saves/loads', ->
    origsaved = session.date.saved
    state = session._saves()
    expect(origsaved).not.toEqual session.date.saved

    # session is nonequal because of its class/ctor, so use an object for later compares
    orig = _.clone session
    loaded = session._loads state
    expect(orig.date.loaded).not.toEqual loaded.date.loaded
    delete orig.date.loaded
    delete loaded.date.loaded
    expect(loaded).toEqual orig
