 # Character.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  attributes:
    user:
      model: 'user'
      required: true
    name:
      type: 'string'
      size: 20
      required: true
    state:
      type: 'json'
      required: true
    deleted:
      type: 'boolean'
      defaultsTo: false
    source:
      type: 'string'
      enum: ['unspecified', 'connectLegacy']
      size: 20
      defaultsTo: 'unspecified'
      required: true
    # TODO
    #commands:
    #  collection: 'command'
    #  via: 'character'
