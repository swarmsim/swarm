'use strict'

describe 'Service: game integration', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  game = {}
  beforeEach inject (_game_) ->
    game = _game_

  clear = (resource) ->
    for u in game.unitlist().concat game.upgradelist()
      u._setCount 0
    # energy cap hack
    game.unit('nexus')._setCount 5 #energy cap hack
    for cost in resource.cost
      cost.unit._setCount cost.val
    
  it "builds one of each unit", ->
    for unit in game.unitlist()
      unit._visible = true
      if not unit.unittype.unbuyable
        clear unit
        expect(unit.count().toNumber()).toBe 0
        unit.buy()
        expect(unit.count().toNumber()).toBe 1

  # This test is really slow after adding decimal.js - had to extend browserNoActivityTimeout. Why?
  # Empower upgrades seem especially slow. Larger numbers...? It's fine in prod outside of tests though.
  it "builds one of each upgrade", ->
    for upgrade in game.upgradelist()
      upgrade._visible = true
      upgrade.unit._visible = true
      clear upgrade
      expect(upgrade.count().toNumber()).toBe 0
      upgrade.buy()
      expect(upgrade.count().toNumber()).toBe 1
