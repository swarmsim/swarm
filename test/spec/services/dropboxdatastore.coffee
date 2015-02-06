'use strict'

describe 'Service: Dropboxdatastore', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  Dropboxdatastore = {}
  beforeEach inject (_Dropboxdatastore_) ->
    Dropboxdatastore = _Dropboxdatastore_

  it 'should do something', ->
    expect(!!Dropboxdatastore).toBe true
