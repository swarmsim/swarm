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
    # tests are too quick, and I don't wanna bother with DI'ing date right now
    origsaved = session.date.saved = new Date session.date.saved.getTime() - 1
    state = session._saves()
    expect(origsaved).not.toEqual session.date.saved

    # session is nonequal because of its class/ctor, so use an object for later compares
    orig = _.clone session
    loaded = session._loads state
    expect(orig.date.loaded).not.toEqual loaded.date.loaded
    delete orig.date.loaded
    delete loaded.date.loaded
    expect(orig).toEqual loaded

  it 'saves/loads versionless', ->
    encoded = session._saves()
    [version, encoded] = session._splitVersionHeader encoded
    expect(encoded.indexOf '|').toBeLessThan 0
    data = session._loads encoded
    expect(!!data).toBe true

  it 'saves/loads versionful', ->
    encoded = session._saves()
    expect(encoded.indexOf '|').not.toBeLessThan 0
    data = session._loads encoded
    expect(!!data).toBe true
