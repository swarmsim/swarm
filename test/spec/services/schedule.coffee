'use strict'

describe 'Service: schedule', ->

  # load the service's module with a different dt
  beforeEach module 'swarmApp'

  # instantiate service
  schedule = {}
  dt = {}
  beforeEach inject (_schedule_, _dt_) ->
    schedule = _schedule_
    dt = _dt_

  it 'should do something', ->
    expect(!!schedule).toBe true

  it 'counts multiticks', ->
    expect(schedule.elapsedSinceLastTick new Date(0), new Date(0)).toEqual
      rawMillis: 0
      rawSeconds: 0
      millis: 0
      seconds: 0
      ticks: 0
      lastTicked: new Date 0
    expect(schedule.elapsedSinceLastTick new Date(0), new Date(1000)).toEqual
      rawMillis: 1000
      rawSeconds: 1
      millis: 1000
      seconds: 1
      ticks: 10
      lastTicked: new Date 1000
    expect(schedule.elapsedSinceLastTick new Date(0), new Date(999)).toEqual
      rawMillis: 999
      rawSeconds: 0.999
      millis: 900
      seconds: 0.9
      ticks: 9
      lastTicked: new Date 900
    expect(schedule.elapsedSinceLastTick new Date(100), new Date(199)).toEqual
      rawMillis: 99
      rawSeconds: 0.099
      millis: 0
      seconds: 0
      ticks: 0
      lastTicked: new Date 100
