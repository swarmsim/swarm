'use strict'

describe 'Service: upgradetype', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  upgradetypes = {}
  beforeEach inject (_upgradetypes_) ->
    upgradetypes = _upgradetypes_

  it 'should parse the spreadsheet', ->
    expect(!!upgradetypes).toBe true
    expect(!!upgradetypes.list).toBe true
    expect(upgradetypes.list.length).toBeGreaterThan 4
