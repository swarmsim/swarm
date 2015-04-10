Sails = new require('sails').Sails()
sails = null

# no need to `require assert` in every test!
global.assert = require 'assert'
global.sinon = require 'sinon'

before (done) ->
  @timeout 10000
  Sails.lift
    # configuration for testing purposes
    models:
      connection: 'memory'
      migrate: 'drop'
    (err, server) ->
      sails = server
      if err
        return done err
      # here you can load fixtures, etc.
      done err, sails

after (done) ->
  # here you can clear fixtures, etc.
  sails.lower done
