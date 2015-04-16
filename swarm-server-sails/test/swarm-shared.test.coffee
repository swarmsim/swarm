shared = require 'swarm-shared'
describe 'swarm-shared integration', ->
  it 'imports swarm-shared', ->
    assert !!shared
    assert !!shared.swarmShared
