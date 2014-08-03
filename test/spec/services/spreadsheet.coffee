'use strict'

describe 'Service: spreadsheet', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  spreadsheet = {}
  beforeEach inject (_spreadsheet_) ->
    spreadsheet = _spreadsheet_

  it 'should do something', ->
    expect(!!spreadsheet).toBe true
