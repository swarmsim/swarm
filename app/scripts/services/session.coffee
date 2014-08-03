'use strict'

###*
 # @ngdoc service
 # @name swarmApp.session
 # @description
 # # session
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'session', -> new class Session
  constructor: ->
    @reset() # TODO remove me
    try
      @load()
      console.log 'Game data loaded successfully.', this
    catch
      console.warn 'Failed to load saved data! Resetting.'
      @reset()

  reset: ->
    @id = 0 # TODO: multiple characters
    @units = {}

  _replacer: (key, val) ->
    return val
  _reviver: (key, val) ->
    return val

  _saves: (data) ->
    #btoa JSON.stringify this
    JSON.stringify data, @_replacer
  _loads: (encoded) ->
    #atob JSON.parse encoded, @_reviver
    JSON.parse encoded, @_reviver
  
  save: ->
    localStorage.setItem this.id, @_saves this

  load: (id=0) ->
    _.extend this, @_loads localStorage.getItem id
