'use strict'

###*
 # @ngdoc service
 # @name swarmApp.session
 # @description
 # # session
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'session', ($rootScope, $log, util, version, env) ->
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
      @id = env.saveId
      $log.debug 'save id', @id
      util.assert @id, 'no save id defined'
      @reset()

    reset: ->
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
      @skippedMillis = 0
      @version =
        started: version
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
        [saveversion, encoded] = encoded.split VERSION_DELIM
      # version may be undefined
      return [saveversion, encoded]
    _validateSaveVersion: (saveversion='0.1.0', gameversion=version) ->
      [sM, sm, sp] = saveversion.split('.').map (n) -> parseInt n
      [gM, gm, gp] = gameversion.split('.').map (n) -> parseInt n
      # during beta, 0.n.0 resets all games from 0.n-1.x. Don't import older games.
      if sM == gM == 0 and sm != gm
        throw new Error 'Beta save from different minor version'
      # No importing 1.0.x games into 0.2.x. Need this for publictest.
      # Importing 0.2.x into 1.0.x is fine.
      # Keep in mind - 0.2.x might not be running this code, but older code that resets at 1.0. (Should make no difference.)
      if (sM > 0) and (gM == 0)
        throw new Error '1.0 save in 0.x game'
      # 0.1.x saves are blacklisted for 1.0.x, already reset
      if (gM > 0) and (sM == 0) and (sm < 2)
        throw new Error 'nice try, no 0.1.x saves'
      ## save state must not be newer than the game running it
      ## actually, let's allow this. support for fast rollbacks is more important.
      #if sM > gM or (sM == gM and (sm > gm or (sm == gm and sp > gp)))
      #  throw new Error "save version newer than game version: #{saveversion} > #{gameversion}"

      # coffeescript: two-dot range is inclusive
      blacklisted = ('1.0.0-publictest'+i for i in [0..8])
      if _.contains blacklisted, saveversion
        throw new Error 'blacklisted save version'

    _loads: (encoded) ->
      #encoded = atob encoded
      [saveversion, encoded] = @_splitVersionHeader encoded
      # don't compare this saveversion for validity! it's only for figuring out changing save formats.
      encoded = encoded.substring PREFIX.length
      #encoded = sjcl.decrypt KEY, encoded
      #encoded = LZString.decompressFromUTF16 encoded
      encoded = LZString.decompressFromBase64 encoded
      ret = JSON.parse encoded, @_reviver
      # special case dates. JSON.stringify replacers and toJSON do not get along.
      for key, val of ret.date
        ret.date[key] = new Date val
      ret.date.loaded = new Date()
      # check save version for validity
      @_validateSaveVersion ret.version?.started
      ret.id = env.saveId
      # bigdecimals. toPrecision avoids decimal.js precision errors when converting old saves.
      for obj of [ret.unittypes, ret.upgrades]
        for key, val of obj
          if _.isNumber val
            val = val.toPrecision 15
          obj[key] = new Decimal val
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

    getStoredSaveData: (id=@id) ->
      localStorage.getItem id

    load: (id) ->
      @importSave @getStoredSaveData id
