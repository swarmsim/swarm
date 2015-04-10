# examples: https://github.com/jaredhanson/passport-local/blob/master/test/strategy.test.js
# TODO: this should be an integration test!
Strategy = require '../../../lib/passport-kongregate/strategy'
stream = require 'stream'
validator = require('express-validator')()

mkres = (data) ->
  # http://stackoverflow.com/questions/12755997/how-to-create-streams-from-string-in-node-js
  s = new stream.Readable()
  s.push JSON.stringify data
  s.push null
  return s

stubreq = (done) ->
  # http://jaketrent.com/post/testing-express-validator/
  req =
    query: {}
    params: {}
    body: {}
    param: (name) ->
      @params[name]

  validator req, {}, ->
    done req

describe 'kongregate passport', ->
  beforeEach =>

  it 'inits', =>
    assert.equal 'kongregate', new Strategy({apiKey: 'blah'}, ->).name
    assert.throws -> new Strategy {}, ->
    assert.throws -> new Strategy {apiKey: 'blah'}
    assert.doesNotThrow -> new Strategy {apiKey: 'blah'}, ->

  it 'auths successfully', (done) =>
    @user = {}
    @https =
      get: sinon.spy (url, cb) =>
        cb mkres {success:true}
    @login = sinon.spy (id, token, cb) =>
      cb null, @user
    @strategy = new Strategy {apiKey: 'thekey', https: @https}, @login
    @strategy.fail = @strategy.error = sinon.stub().throws()
    @strategy.success = (user, info) =>
      assert.equal @user, user
      assert @https.get.calledOnce
      assert @login.calledOnce
      done()
    stubreq (req) =>
      req.params =
        policy:
          user_id: 111
          game_auth_token: 'token'
      @strategy.authenticate req
