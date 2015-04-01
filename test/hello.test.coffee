assert = require 'assert'

describe.only 'hello coffee', ->
  it 'runs the test', (done) ->
    done()
  xit 'fails the test', (done) ->
    assert.ok false
    done()
  xit 'breaks the test', (done) ->
    throw new Error 'howdy'
