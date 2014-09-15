'use strict'

###*
 # @ngdoc service
 # @name swarmApp.session
 # @description
 # # session
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'session', ($rootScope, $log, util, version) ->
  # TODO separate file, outside of source control?
  # Client-side encryption is inherently insecure anyway, probably not worth it.
  # All we can do is prevent the most casual of savestate hacking.
  #KEY = "jSmP4RnN994f58yR3UZRKhmK"
  # LZW is obfuscated enough. No more encryption.
  PREFIX = btoa "Cheater :(\n\n"
  # The encoded string starts with an encoded version number. Older savestates
  # might not, so if this is missing, no biggie.
  VERSION_DELIM = '|'

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
      @upgrades = {}
      @statistics = {}
      @achievements = {}
      $rootScope.$emit 'reset', {session:this}

    _replacer: (key, val) ->
      #if _.isDate val
      #  $log.debug 'replace date', val
      #  return {__class__:'Date',val:val.toJSON()}
      return val
    _reviver: (key, val) ->
      #if val.__class__=='Date'
      #  $log.debug 'revive date', val
      #  return new Date val.val
      return val

    # non-encoded json session-state data. Intended for error logging.
    jsonSaves: (data=this) ->
      JSON.stringify data, @_replacer

    _saves: (data=this, setdates=true) ->
      util.assert (not data._exportCache?), "exportCache is defined while saving: saves will contain saves. Uh-oh."
      if setdates
        data.date.saved = new Date()
        delete data.date.loaded
      ret = @jsonSaves data
      ret = LZString.compressToBase64 ret
      #ret = LZString.compressToUTF16 ret
      #ret = sjcl.encrypt KEY, ret
      ret = PREFIX + ret
      # version is saved separately from json in case save format changes
      ret = "#{btoa version}#{VERSION_DELIM}#{ret}"
      #ret = btoa ret
      return ret
    _hasVersionHeader: (encoded) ->
      encoded.indexOf(VERSION_DELIM) >= 0
    _splitVersionHeader: (encoded) ->
      if @_hasVersionHeader encoded
        [version, encoded] = encoded.split VERSION_DELIM
      # version may be undefined
      return [version, encoded]
    _loads: (encoded) ->
      #encoded = atob encoded
      [version, encoded] = @_splitVersionHeader encoded
      encoded = encoded.substring PREFIX.length
      #encoded = sjcl.decrypt KEY, encoded
      #encoded = LZString.decompressFromUTF16 encoded
      encoded = LZString.decompressFromBase64 encoded
      ret = JSON.parse encoded, @_reviver
      # special case dates. JSON.stringify replacers and toJSON do not get along.
      for key, val of ret.date
        ret.date[key] = new Date val
      ret.date.loaded = new Date()
      return ret

    exportSave: ->
      if not @_exportCache?
        # this happens on page load, when we haven't saved
        @_exportCache = @_saves undefined, false
      @_exportCache

    importSave: (encoded) ->
      data = @_loads encoded
      _.extend this, data
      @_exportCache = encoded
    
    save: ->
      # exportCache is necessary because sjcl encryption isn't deterministic,
      # but exportSave() must be ...not necessarily deterministic, but
      # consistent enough to not confuse angular's $apply().
      # Careful to delete it while saving, so saves don't contain other saves recursively!
      # TODO: refactor so it's in another object and we don't have to do this exclusion silliness
      delete @_exportCache
      @_exportCache = @_saves()
      localStorage.setItem this.id, this._exportCache
      $rootScope.$emit 'save', this

    load: (id=0) ->
      @importSave localStorage.getItem id
