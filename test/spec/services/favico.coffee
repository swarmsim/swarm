'use strict'

describe 'Service: favico', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  favico = {}
  beforeEach inject (_favico_) ->
    favico = _favico_

  it 'should do something', ->
    expect(!!favico).toBe true
