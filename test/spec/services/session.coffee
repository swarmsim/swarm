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

  it 'validates the save version programmatically', ->
    expect(-> session._validateSaveVersion '0.1.0', '0.1.0').not.toThrow()
    expect(-> session._validateSaveVersion '0.1.0', '0.1.30').not.toThrow()
    # we're allowing older version imports
    expect(-> session._validateSaveVersion '0.1.30', '0.1.0').not.toThrow()
    # but beta minor versions are a reset
    expect(-> session._validateSaveVersion '0.1.30', '0.2.0').toThrow()
    expect(-> session._validateSaveVersion '0.2.30', '0.3.0').toThrow()
    # no importing 0.2.0 games into 0.1.0 either
    expect(-> session._validateSaveVersion '0.2.0', '0.1.30').toThrow()
    expect(-> session._validateSaveVersion '0.3.0', '0.2.30').toThrow()

    expect(-> session._validateSaveVersion '0.2.30', '0.2.0').not.toThrow()
    expect(-> session._validateSaveVersion '0.2.0', '0.2.0').not.toThrow()
    expect(-> session._validateSaveVersion '1.0.0', '1.0.0').not.toThrow()
    # 0.x to 1.0 is a reset too, no imports
    expect(-> session._validateSaveVersion '0.9.0', '1.0.0').toThrow()
    expect(-> session._validateSaveVersion '1.9.0', '1.0.0').not.toThrow()
    expect(-> session._validateSaveVersion '1.0.0', '1.9.0').not.toThrow()
    # major versions after 1.0 aren't resets
    expect(-> session._validateSaveVersion '2.0.0', '1.0.0').not.toThrow()
    expect(-> session._validateSaveVersion '1.0.0', '2.0.0').not.toThrow()
    # default version - very old saves.
    expect(-> session._validateSaveVersion undefined, '0.1.0').not.toThrow()
    expect(-> session._validateSaveVersion undefined, '0.2.0').toThrow()
    # current-version based. breaks when we upgrade to 0.2.0!
    expect(-> session._validateSaveVersion '0.1.0').not.toThrow()
    expect(-> session._validateSaveVersion undefined).not.toThrow()

  it 'validates the save version on import', inject (version) ->
    session.version.started = '0.0.1'
    encoded = session._saves()
    expect(-> session._loads encoded).toThrow()
    session.version.started = '1.0.0'
    encoded = session._saves()
    expect(-> session._loads encoded).toThrow()
    session.version.started = version
    encoded = session._saves()
    expect(-> session._loads encoded).not.toThrow()
    delete session.version
    encoded = session._saves()
    expect(-> session._loads encoded).not.toThrow()
