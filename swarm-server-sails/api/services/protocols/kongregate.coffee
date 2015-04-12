validator = require 'validator'
crypto    = require 'crypto'

# Kongregate Authentication Protocol
#
# based on ./local.js

exports.register = (req, res, next) ->
  id = req.param 'user_id'
  game_token = req.param 'game_auth_token'

  if !id
    req.flash 'error', 'Error.Passport.Kongregate.Id.Missing'
    return next new Error 'No userid was entered.'
  if !game_token
    req.flash 'error', 'Error.Passport.Kongregate.Token.Missing'
    return next new Error 'No game_auth_token was entered.'

  User.create
    username : username
    email    : email
    (err, user) ->
      if err
        return next err

    # Generating accessToken for API authentication
    passport_token = crypto.randomBytes(48).toString 'base64'

    Passport.create
      protocol    : 'kongregate'
      kongregateUserId: id
      # TODO should we be hashing game_auth_tokens? they're sort of like a
      # password... but they're *required* to interact with the kong server as
      # this user, so we can't hash them. maybe encrypt them?
      gameAuthToken : game_token
      user        : user.id
      accessToken : token
      (err, passport) ->
        if err
          return user.destroy (destroyErr) ->
            next destroyErr || err

        next null, user

exports.connect = (req, res, next) ->
  user = req.user
  id = req.param 'user_id'
  game_token = req.param 'game_auth_token'

  Passport.findOne
    protocol : 'kongregate'
    user     : user.id
    (err, passport) ->
      if err
        return next err

      if !passport
        Passport.create
          protocol : 'kongregate'
          kongregateUserId : id
          gameAuthToken: game_token
          user     : user.id
          (err, passport) ->
            next err, user
      else
        next null, user

exports.login = (req, id, game_token, next) ->
    Passport.findOne
      protocol : 'kongregate'
      kongregateUserId : id
      gameAuthToken: game_token
      (err, passport) ->
        if passport
          return next null, user
        else
          req.flash 'error', 'Error.Passport.Kongregate.Id.NotSet'
          return next null, false
