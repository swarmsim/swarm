# Kongregate auth strategy. Cribbed a lot from these:
# https://github.com/jaredhanson/passport-local/blob/master/lib/strategy.js
# https://github.com/yuri-karadzhov/passport-hash/blob/master/lib/passport-hash/strategy.js
passport = require 'passport'
util = require 'util'
Https = require 'https'
querystring = require 'querystring'

textResponse = (res, callback) ->
  body = ''
  res.on 'data', (chunk) ->
    body += chunk
  res.on 'end', ->
    callback body

jsonResponse = (res, callback) ->
  textResponse res, (body, res) ->
    callback JSON.parse body

module.exports = class Strategy extends passport.Strategy
  constructor: (@options, @_verify) ->
    if not @options?.apiKey?
      throw new Error 'options.apikey required'
    if not @_verify?
      throw new Error 'verify fn required'

    @name = 'kongregate'
    super()

  authenticate: (req) ->
    req.checkParams('policy.user_id').notEmpty().isInt()
    req.checkParams('policy.game_auth_token').notEmpty()
    if (errors=req.validationErrors())
      res.send JSON.stringify(errors:errors), 400
      return
    policy = req.params.policy
    kong_args = {user_id:policy.user_id, game_auth_token:policy.game_auth_token, api_key:@options.apiKey}
    kong_url = "https://api.kongregate.com/api/authenticate.json?#{querystring.stringify kong_args}"

    verified = (err, user, info) =>
      if err
        return @error err
      if !user
        return @fail info
      @success user, info

    https = @options.https ? Https
    https.get kong_url, (kongres) =>
      jsonResponse kongres, (kongjson) =>
        if kongjson.success
          if @options._passReqToCallback
            @_verify req, policy.user_id, policy.game_auth_token, verified
          else
            @_verify policy.user_id, policy.game_auth_token, verified
        else
          if 400 <= kongjson.error < 500
            @fail JSON.stringify kongjson
          else
            @error JSON.stringify kongjson
    .on 'error', (e) =>
      @error e
