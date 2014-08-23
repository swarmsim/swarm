'use strict'

describe 'Service: command', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  commands = {}
  beforeEach inject (_commands_) ->
    commands = _commands_

  it 'should do something', ->
    expect(!!commands).toBe true
