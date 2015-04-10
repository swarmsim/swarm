passport = require 'passport'
util = require 'util'

Strategy = (@options, @_verify) ->
  if not @options?.apiKey?
    throw new Error 'options.apikey required'
  if not @_verify?
    throw new Error 'verify fn required'

  passport.Strategy.call this
  @name = 'kongregate'
