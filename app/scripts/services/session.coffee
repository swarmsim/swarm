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
    @unittypes = {}
    now = new Date()
    @date =
      started: now
      restarted: now
      saved: now
      loaded: now

  _replacer: (key, val) ->
    #if _.isDate val
    #  console.log 'replace date', val
    #  return {__class__:'Date',val:val.toJSON()}
    return val
  _reviver: (key, val) ->
    #if val.__class__=='Date'
    #  console.log 'revive date', val
    #  return new Date val.val
    return val

  # non-encoded json session-state data. Intended for error logging.
  jsonSaves: (data=this) ->
    JSON.stringify data, @_replacer

  _saves: (data=this) ->
    #btoa JSON.stringify this
    data.date.saved = new Date()
    delete data.date.loaded
    @jsonSaves data
  _loads: (encoded) ->
    #atob JSON.parse encoded, @_reviver
    ret = JSON.parse encoded, @_reviver
    # special case dates. JSON.stringify replacers and toJSON do not get along.
    for key, val of ret.date
      ret.date[key] = new Date val
    ret.date.loaded = new Date()
    return ret
  
  save: ->
    console.log 'session.save'
    localStorage.setItem this.id, @_saves()

  load: (id=0) ->
    _.extend this, @_loads localStorage.getItem id
