'use strict'

describe 'Service: upgrade', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  upgrades = {}
  beforeEach inject (_upgrades_) ->
    upgrades = _upgrades_

  it 'should parse the spreadsheet', ->
    expect(!!upgrades).toBe true
    expect(!!upgrades.list).toBe true
    expect(upgrades.list.length).toBeGreaterThan 0
