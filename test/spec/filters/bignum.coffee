'use strict'

describe 'Filter: bignum', ->

  # load the filter's module
  beforeEach module 'swarmApp'

  # initialize a new instance of the filter before each test
  bignum = {}
  beforeEach inject ($filter) ->
    bignum = $filter 'bignum'

  it 'should format numbers', ->
    expect(bignum 1).toBe '1'
    expect(bignum 10).toBe '10'
    expect(bignum 100).toBe '100'
    # toLocaleString works in browsers, but not node :(
    #expect(bignum 1000).toBe '1,000'
    #expect(bignum 10000).toBe '10,000'
    #expect(bignum 11111).toBe '11,111'
    expect(bignum 100000).toBe '1.00e+5'
    expect(bignum 111111).toBe '1.11e+5'
    expect(bignum 1e6).toBe '1.00e+6'
    expect(bignum 1111111).toBe '1.11e+6'
    expect(bignum 1e7).toBe '1.00e+7'
    expect(bignum 11111111).toBe '1.11e+7'
