'use strict'

describe 'Service: parsenumber', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  parseNumber = {}
  Game = {}
  beforeEach inject (_parseNumber_, _Game_) ->
    parseNumber = _parseNumber_
    Game = _Game_

  mkgame = (unittypes, reified=new Date 0) ->
    game = new Game {unittypes: unittypes, upgrades:{}, date:{reified:reified,started:reified,restarted:reified}, save:->}
    game.now = new Date 0
    return game

  it 'should do something', ->
    expect(!!parseNumber).toBe true

  it 'parses numbers in different formats', ->
    expect(parseNumber('12345').toNumber()).toBe 12345
    expect(parseNumber('12,345').toNumber()).toBe 12345
    expect(parseNumber(12345).toNumber()).toBe 12345
    expect(parseNumber(new Decimal 12345).toNumber()).toBe 12345
    expect(parseNumber('12.345e3').toNumber()).toBe 12345
    expect(parseNumber('12.345E3').toNumber()).toBe 12345
    expect(parseNumber('12.345e+3').toNumber()).toBe 12345
    expect(parseNumber('12.345E+3').toNumber()).toBe 12345
    expect(parseNumber('fgsfds')).toBeUndefined()
    expect(parseNumber('12e')).toBeUndefined()
    expect(parseNumber('12E')).toBeUndefined()
    expect(parseNumber('-1').toNumber()).toBe 1
    expect(parseNumber('0').toNumber()).toBe 1
    expect(parseNumber('12.999').toNumber()).toBe 12
    # exceed js max number
    expect(parseNumber('1e3000')+'').toBe '1e+3000'
    expect(parseNumber('55e3000')+'').toBe '5.5e+3001'

  it 'parses number with fancy suffixes', ->
    expect(parseNumber('12 thousand').toNumber()).toBe 12000
    expect(parseNumber('12.345 thousand').toNumber()).toBe 12345
    expect(parseNumber('12k').toNumber()).toBe 12000
    expect(parseNumber('12.345k').toNumber()).toBe 12345
    expect(parseNumber('12.345 ThOuSaNd').toNumber()).toBe 12345
    expect(parseNumber('12.345K').toNumber()).toBe 12345
    expect(parseNumber('12 million').toNumber()).toBe 12e6
    expect(parseNumber('12 billion').toNumber()).toBe 12e9
    expect(parseNumber('12 trillion').toNumber()).toBe 12e12
    expect(parseNumber('12 quadrillion').toNumber()).toBe 12e15
    expect(parseNumber('12 brazillion')).toBeUndefined()
    expect(parseNumber('12m').toNumber()).toBe 12e6
    expect(parseNumber('12b').toNumber()).toBe 12e9
    expect(parseNumber('12t').toNumber()).toBe 12e12
    expect(parseNumber('12q')).toBeUndefined()
    expect(parseNumber('12qa').toNumber()).toBe 12e15

  it 'parses cost-percents', ->
    game = mkgame {larva:'9e9999', meat:100}
    unit = game.unit 'drone'
    expect(parseNumber('100%', unit).toNumber()).toBe 10
    expect(parseNumber('50%', unit).toNumber()).toBe 5
    expect(parseNumber('49.99999%', unit).toNumber()).toBe 4
    expect(parseNumber('0%', unit).toNumber()).toBe 1 #minimum
    expect(parseNumber('-1%', unit).toNumber()).toBe 1
    expect(parseNumber('9999%', unit).toNumber()).toBe 10 #max

  it 'parses twins', ->
    game = mkgame {larva:'9e9999', meat:'1e99999'}
    unit = game.unit 'drone'
    upgrade = game.upgrade 'dronetwin'
    expect(upgrade.count().toNumber()).toBe 0
    expect(unit.twinMult().toNumber()).toBe 1
    expect(parseNumber('=1000', unit).toNumber()).toBe 1000

    upgrade._setCount(1)
    expect(unit.twinMult().toNumber()).toBe 2
    expect(parseNumber('=1000', unit).toNumber()).toBe 500
    expect(parseNumber('=1001', unit).toNumber()).toBe 501 # round up

    upgrade._setCount(3)
    expect(unit.twinMult().toNumber()).toBe 8
    expect(parseNumber('=100', unit).toNumber()).toBe 13
    expect(parseNumber('=1000', unit).toNumber()).toBe 125
    expect(parseNumber('=1001', unit).toNumber()).toBe 126

    # plays nice with other formats
    expect(parseNumber('=1k', unit).toNumber()).toBe 125
    expect(parseNumber('=1.001k', unit).toNumber()).toBe 126
    expect(parseNumber('=1 thousand', unit).toNumber()).toBe 125

  it 'parses a target value', ->
    game = mkgame {drone:0, larva:'9e9999', meat:'1e99999'}
    unit = game.unit 'drone'
    upgrade = game.upgrade 'dronetwin'
    expect(upgrade.count().toNumber()).toBe 0
    expect(unit.twinMult().toNumber()).toBe 1
    expect(parseNumber('@1000', unit).toNumber()).toBe 1000

    unit._setCount 200
    expect(parseNumber('@1000', unit).toNumber()).toBe 800

    upgrade._setCount(1)
    unit._setCount 0
    expect(unit.twinMult().toNumber()).toBe 2
    expect(parseNumber('@1000', unit).toNumber()).toBe 500
    expect(parseNumber('@1001', unit).toNumber()).toBe 501 # round up

    upgrade._setCount(3)
    expect(unit.twinMult().toNumber()).toBe 8
    expect(parseNumber('@100', unit).toNumber()).toBe 13
    expect(parseNumber('@1000', unit).toNumber()).toBe 125
    expect(parseNumber('@1001', unit).toNumber()).toBe 126

    # plays nice with other formats
    expect(parseNumber('@1k', unit).toNumber()).toBe 125
    expect(parseNumber('@1.001k', unit).toNumber()).toBe 126
    expect(parseNumber('@1 thousand', unit).toNumber()).toBe 125

    unit._setCount 200
    expect(parseNumber('@100', unit).toNumber()).toBe 1 # 1 is the minimum, no matter what
    expect(parseNumber('@1000', unit).toNumber()).toBe 100
    expect(parseNumber('@1k', unit).toNumber()).toBe 100

  it 'parses =n%, #617', ->
    game = mkgame {drone:0, larva:'9e9999', meat:'1e99999'}
    unit = game.unit 'drone'
    expect(parseNumber('=50%', unit).toNumber()).toBe 1
