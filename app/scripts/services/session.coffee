'use strict'

###*
 # @ngdoc service
 # @name swarmApp.session
 # @description
 # # session
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'session', (env) ->
  # TODO separate file, outside of source control?
  # Client-side encryption is inherently insecure anyway, probably not worth it.
  # All we can do is prevent the most casual of savestate hacking.
  KEY = "jSmP4RnN994f58yR3UZRKhmK"
  PREFIX = "Cheater :(\n\n"

  return new class Session
    constructor: ->
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
        reified: now
      @options = {}

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

    _saves: (data=this, setdates=true) ->
      if setdates
        data.date.saved = new Date()
        delete data.date.loaded
      ret = @jsonSaves data
      ret = sjcl.encrypt KEY, ret
      ret = PREFIX + ret
      ret = btoa ret
      return ret
    _loads: (encoded) ->
      encoded = atob encoded
      encoded = encoded.substring PREFIX.length
      encoded = sjcl.decrypt KEY, encoded
      ret = JSON.parse encoded, @_reviver
      # special case dates. JSON.stringify replacers and toJSON do not get along.
      for key, val of ret.date
        ret.date[key] = new Date val
      ret.date.loaded = new Date()
      return ret

    exportSave: ->
      return btoa @_saves this, false
    
    save: ->
      localStorage.setItem this.id, @_saves()

    load: (id=0) ->
      _.extend this, @_loads localStorage.getItem id
