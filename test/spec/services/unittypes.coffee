'use strict'

describe 'Service: unittypes', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  unittypes = {}
  UnitTypes = {}
  UnitType = {}
  beforeEach inject (_unittypes_, _UnitTypes_, _UnitType_) ->
    unittypes = _unittypes_
    UnitTypes = _UnitTypes_
    UnitType = _UnitType_

  sorted = (list) ->
    ret = _.clone list
    ret.sort()
    return ret
  it 'should do something', ->
    expect(!!unittypes).toBe true

  it 'should build a production-graph', ->
    expect(sorted _.keys unittypes.byName.meat.producerPath).toEqual sorted ['drone', 'queen', 'nest', 'hive']
    expect(unittypes.byName.meat.producerNames().hive).toEqual ['hive', 'nest', 'queen', 'drone']
    expect(unittypes.byName.meat.producerNames()).toEqual
      hive: ['hive', 'nest', 'queen', 'drone']
      nest: ['nest', 'queen', 'drone']
      queen: ['queen', 'drone']
      drone: ['drone']
    expect(unittypes.byName.drone.producerNames()).toEqual
      hive: ['hive', 'nest', 'queen']
      nest: ['nest', 'queen']
      queen: ['queen']
    expect(unittypes.byName.queen.producerNames()).toEqual
      hive: ['hive', 'nest']
      nest: ['nest']
    expect(unittypes.byName.nest.producerNames()).toEqual
      hive: ['hive']
    expect(unittypes.byName.hive.producerNames()).toEqual {}
