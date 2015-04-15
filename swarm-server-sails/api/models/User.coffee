 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  schema: true

  attributes:
    # <passport-required-fields>
    username:
      type: 'string'
      unique: true
    email:
      type: 'email'
      unique: true
    passports:
      collection: 'Passport'
      via: 'user'
    # </passport-required-fields>
    characters:
      collection: 'character'
      via: 'user'
