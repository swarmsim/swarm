'use strict'

describe 'Service: userApi', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  userApi = {}
  beforeEach inject (_userApi_) ->
    userApi = _userApi_

  it 'should do something', ->
    expect(!!userApi).toBe true
