Sails = new require('sails').Sails()
sails = null

global.assert = require 'assert'

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
