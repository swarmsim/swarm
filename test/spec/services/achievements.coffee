'use strict'

describe 'Service: achievements', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  achievements = {}
  Achievement = {}
  beforeEach inject (_achievements_, _Achievement_) ->
    achievements = _achievements_
    Achievement = _Achievement_

  it 'should do something', ->
    expect(!!achievements).toBe true
    expect(achievements.list.length).toBeGreaterThan 0
  
  it 'earns', ->
    game = {session:{achievements:{}}}
    achieve = new Achievement game, achievements.byName.drone1
    expect(achieve.isEarned()).toBe false
    expect(achieve.earnedAtMillisElapsed()).toBeUndefined()
    expect(achieve.pointsEarned()).toBe 0
    achieve.earn 55
    expect(achieve.isEarned()).toBe true
    expect(achieve.earnedAtMillisElapsed()).toBe 55
    expect(achieve.pointsEarned()).toBe 10
