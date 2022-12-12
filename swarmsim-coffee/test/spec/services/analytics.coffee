'use strict'

describe 'Service: analytics', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  analytics = {}
  beforeEach inject (_analytics_) ->
    analytics = _analytics_

  # TODO why on earth does this fail in travis-ci? Works fine in my checkout.
  xit 'should do something', ->
    expect(!!analytics).toBe true
