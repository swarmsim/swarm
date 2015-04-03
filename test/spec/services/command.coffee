'use strict'

describe 'Service: command', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  commands = {}
  game = {}
  beforeEach inject (_commands_, _game_) ->
    commands = _commands_
    game = _game_

  it 'should do something', ->
    expect(!!commands).toBe true

  it 'can undo', ->
    game.unit('meat')._setCount 10000
    game.unit('larva')._setCount 10000
    drone = game.unit 'drone'
    expect(drone.count().toNumber()).toBe 0

    commands.buyUnit unit:drone, num:1
    expect(!!commands._undo.isRedo).not.toBe true
    expect(drone.count().toNumber()).toBe 1

    commands.undo()
    expect(!!commands._undo.isRedo).toBe true
    expect(drone.count().toNumber()).toBe 0

    commands.undo()
    expect(!!commands._undo.isRedo).toBe true
    expect(drone.count().toNumber()).toBe 1
