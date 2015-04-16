'use strict'

describe 'swarm-shared usage', ->
  it 'imports swarm-shared', ->
    expect(!!require).toBe true
    shared = require 'swarm-shared'
    expect(!!shared).toBe true
    expect(!!shared.swarmShared).toBe true
