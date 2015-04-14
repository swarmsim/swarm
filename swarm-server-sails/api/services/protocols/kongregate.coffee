# Kongregate Authentication Protocol
#
# based on ./local.js

module.exports = (req, creds, profile, done) ->
  query =
    identifier: creds.user_id
    protocol: 'kongregate'
    tokens:
      game_auth_token: creds.game_auth_token

  passport.connect req, query, profile, done
