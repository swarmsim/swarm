'use strict'

describe 'Service: effecttypes', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  effecttypes = {}
  beforeEach inject (_effecttypes_) ->
    effecttypes = _effecttypes_

  it 'should do something', ->
    expect(!!effecttypes).toBe true

  it 'validates mult vs add - effects must be commutative', ->
    schema = {}
    stats = {}
    effecttypes.byName.multStat.calcStats {stat:'x',val:3}, stats, schema, 1
    expect(stats.x).toBe 3
    effecttypes.byName.multStat.calcStats {stat:'x',val:3}, stats, schema, 2
    expect(stats.x).toBe 27
    effecttypes.byName.addStat.calcStats {stat:'t',val:3}, stats, schema, 1
    expect(stats.t).toBe 3
    effecttypes.byName.addStat.calcStats {stat:'t',val:3}, stats, schema, 3
    expect(stats.t).toBe 12
    expect(-> effecttypes.byName.addStat.calcStats {stat:'x',val:3}, stats, schema, 1).toThrow()
    expect(-> effecttypes.byName.multStat.calcStats {stat:'t',val:3}, stats, schema, 1).toThrow()
