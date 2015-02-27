'use strict'

describe 'Service: storage', ->
  class MemoryStorage
    constructor: (@data={}) ->
    getItem: (key) ->
      return @data[key]
    setItem: (key, val) ->
      @data[key] = val
    removeItem: (key) ->
      delete @data[key]

  class BrokenStorage
    getItem: -> throw new Error 'broken get'
    setItem: -> throw new Error 'broken set'
    removeItem: -> throw new Error 'broken remove'

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  storage = {}
  MultiStorage = {}
  beforeEach inject (_storage_, _MultiStorage_) ->
    storage = _storage_
    MultiStorage = _MultiStorage_

  it 'should do something', ->
    expect(!!storage).toBe true

  it 'adds stores, writes, reads', ->
    store = new MultiStorage()
    store.addStorage 'one', new MemoryStorage()
    store.addStorage 'two', new MemoryStorage()

    expect(store.getItem 'key').toBeUndefined()
    expect(store.one.getItem 'key').toBeUndefined()
    expect(store.two.getItem 'key').toBeUndefined()
    store.setItem 'key', 3
    expect(store.getItem 'key').toBe 3
    expect(store.one.getItem 'key').toBe 3
    expect(store.two.getItem 'key').toBe 3
    store.removeItem 'key'
    expect(store.getItem 'key').toBeUndefined()
    expect(store.one.getItem 'key').toBeUndefined()
    expect(store.two.getItem 'key').toBeUndefined()

  it 'reads from one store, in order, if others are missing or broken', ->
    store = new MultiStorage()
    store.addStorage 'broken', new BrokenStorage()
    store.addStorage 'missing', new MemoryStorage()
    store.addStorage 'good', new MemoryStorage()
    store.addStorage 'ignored', new MemoryStorage()

    store.good.setItem 'key', 3
    store.ignored.setItem 'key', 13
    # store.getitem ignores broken and missing storage, uses the good storage first
    expect(-> store.broken.getItem 'key').toThrow()
    expect(store.missing.getItem 'key').toBeUndefined()
    expect(store.getItem 'key').toBe 3

    # store.setitem sets them all in sync (except broken)
    store.setItem 'key', 4
    expect(-> store.broken.getItem 'key').toThrow()
    expect(store.missing.getItem 'key').toBe 4
    expect(store.good.getItem 'key').toBe 4
    expect(store.ignored.getItem 'key').toBe 4
    expect(store.getItem 'key').toBe 4

  it 'throws an error iff all storages throw an error', ->
    store = new MultiStorage()
    store.addStorage 'one', new BrokenStorage()
    store.addStorage 'two', new BrokenStorage()
    expect(-> store.getItem 'key').toThrow()
    expect(-> store.setItem 'key', 3).toThrow()
    expect(-> store.removeItem 'key').toThrow()
    # but add one working storage, and no error
    store.addStorage 'three', new MemoryStorage()
    expect(-> store.getItem 'key').not.toThrow()
    expect(-> store.setItem 'key', 3).not.toThrow()
    expect(-> store.removeItem 'key').not.toThrow()

  it 'connects to aws', (done) -> inject (awsS3Storage) ->
    withValidation = (fn) ->
      return (err, data) ->
        expect(err).toBeNull()
        return fn data
    thekey = 'testkey'+Math.random()
    awsS3Storage.setItemAsync thekey, 'testval', withValidation (data) ->
      awsS3Storage.getItemAsync thekey, withValidation (data) ->
        expect(data.Body).toBe 'testval'
        awsS3Storage.setItemAsync thekey, {wee:'testval2'}, withValidation (data) ->
          awsS3Storage.getItemAsync thekey, withValidation (data) ->
            expect(data.Body).toEqual {wee:'testval2'}
            awsS3Storage.removeItemAsync thekey, withValidation (data) ->
              #awsS3Storage.getItemAsync thekey, withValidation (data) ->
              #  expect(data).toBeNull()
              done()
