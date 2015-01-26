'use strict'

describe 'Service: util', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  util = {}
  beforeEach inject (_util_) ->
    util = _util_

  it 'should do something', ->
    expect(!!util).toBe true

  it 'sums', ->
    expect(util.sum []).toBe 0
    expect(util.sum [1,2,3]).toBe 6
    expect(util.sum [1,2,-3]).toBe 0

  trees =
    "": ->
    "[2]": [3, null, ->]
    ".a": {a:->}
    ".a.b.c[0].d": {a:{b:{c:[{d:->}]}}}
  for path, tree of trees then do (path, tree) =>
    it "traverses object trees: #{JSON.stringify tree}", ->
      ret = util.walk tree, (obj, path) ->
        if _.isFunction obj
          return path
      expect(ret.length).toBe 1
      expect(ret[0]).toBe path

  it 'imports decimal.js bignums', ->
    expect(!!window.Decimal).toBe true
    expect(!!Decimal).toBe true
    expect(new Decimal('1e+500').times(2).toString()).toBe '2e+500'
