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
    expect(stats.x.toNumber()).toBe 3
    effecttypes.byName.multStat.calcStats {stat:'x',val:3}, stats, schema, 2
    expect(stats.x.toNumber()).toBe 27
    effecttypes.byName.addStat.calcStats {stat:'t',val:3}, stats, schema, 1
    expect(stats.t.toNumber()).toBe 3
    effecttypes.byName.addStat.calcStats {stat:'t',val:3}, stats, schema, 3
    expect(stats.t.toNumber()).toBe 12
    expect(-> effecttypes.byName.addStat.calcStats {stat:'x',val:3}, stats, schema, 1).toThrow()
    expect(-> effecttypes.byName.multStat.calcStats {stat:'t',val:3}, stats, schema, 1).toThrow()

  it 'romanizes', inject (romanize) ->
    expect(romanize 2).toBe 'II'
    expect(romanize 6).toBe 'VI'
    expect(romanize 21).toBe 'XXI'
    expect(romanize 51).toBe 'LI'
    expect(romanize 100).toBe 'C'
    expect(romanize 1000).toBe 'M'
    expect(romanize 3999).toBe 'MMMCMXCIX'
    #expect(romanize 4000).toBe '4000'
