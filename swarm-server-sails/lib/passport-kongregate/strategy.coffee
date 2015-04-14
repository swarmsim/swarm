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
  constructor: (@options, @protocol) ->
    if not @options?.apiKey?
      throw new Error 'options.apikey required'
    if not @protocol?
      throw new Error 'protocol required'

    @name = 'kongregate'
    super()

  authenticate: (req, options={}) ->
    req.checkBody('user_id').notEmpty().isInt()
    req.checkBody('game_auth_token').notEmpty()
    params = req.body
    if (errors=req.validationErrors())
      @fail {errors:errors}, 400
    creds = {user_id:params.user_id, game_auth_token:params.game_auth_token}
    kong_args = _.extend {api_key:@options.apiKey}, creds
    sails.log.debug 'kongregate auth', kong_args
    kong_url = "https://api.kongregate.com/api/authenticate.json?#{querystring.stringify kong_args}"

    verified = (err, user, info) =>
      sails.log.debug 'kongregate auth connected?', err, user, info
      if err
        return @error err
      if !user
        return @fail info
      @success user, info

    https = @options.https ? Https
    https.get kong_url, (kongres) =>
      jsonResponse kongres, (kongjson) =>
        sails.log.debug 'kongregate auth reply', kongjson
        if kongjson.success
          profile =
            user_id: params.user_id
            username: params.username
          @protocol req, creds, profile, verified
        else
          if 400 <= kongjson.error < 500
            @fail JSON.stringify kongjson
          else
            @error JSON.stringify kongjson
    .on 'error', (e) =>
      @error e
