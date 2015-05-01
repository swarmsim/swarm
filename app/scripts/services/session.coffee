'use strict'

angular.module('swarmApp').factory 'saveId', (env, isKongregate) ->
  suffix = if isKongregate() then '-kongregate' else ''
  return "#{env.saveId}#{suffix}"

###*
 # @ngdoc service
 # @name swarmApp.session
 # @description
 # # session
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'session', (storage, $rootScope, $log, util, version, env, saveId, isKongregate) ->
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
      $log.debug 'save id', @id
      util.assert @id, 'no save id defined'

    reset: ->
      now = new Date()
      @id = saveId
      @heartbeatId = "#{@id}:heartbeat"
      @state =
        unittypes: {}
        date:
          started: now
          restarted: now
          saved: now
          loaded: now
          reified: now
          closed: now
        options: {}
        upgrades: {}
        statistics: {}
        achievements: {}
        watched: {}
        skippedMillis: 0
        version:
          started: version
          saved: version
      # undefined if not isKongregate
      if isKongregate()
        @state.kongregate = true
      $rootScope.$broadcast 'reset', {session:this}

    _saves: (data=@state, setdates=true) ->
      if setdates
        data.date.saved = new Date()
        delete data.date.loaded
        data.version?.saved = version
      ret = JSON.stringify data
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
      blacklisted = [/^1\.0\.0-publictest/]
      # never blacklist the current version; also makes tests pass before we do `npm version 1.0.0`
      if saveversion != gameversion
        for b in blacklisted
          if b.test saveversion
            throw new Error 'blacklisted save version'

    _validateFormatVersion: (formatversion, gameversion=version) ->
      # coffeescript: two-dot range is inclusive
      blacklisted = [/^1\.0\.0-publictest/]
      # never blacklist the current version; also makes tests pass before we do `npm version 1.0.0`
      if formatversion != gameversion
        for b in blacklisted
          if b.test formatversion
            throw new Error 'blacklisted save version'

    _loads: (encoded) ->
      # ignore whitespace
      encoded = encoded.replace /\s+/g, ''
      $log.debug 'decoding imported game. len', encoded?.length
      #encoded = atob encoded
      [saveversion, encoded] = @_splitVersionHeader encoded
      # don't compare this saveversion for validity! it's only for figuring out changing save formats.
      # (with some exceptions, like publictest.)
      encoded = encoded.substring PREFIX.length
      #encoded = sjcl.decrypt KEY, encoded
      #encoded = LZString.decompressFromUTF16 encoded
      encoded = LZString.decompressFromBase64 encoded
      $log.debug 'decompressed imported game successfully', [encoded]
      ret = JSON.parse encoded
      # special case dates. JSON.stringify replacers and toJSON do not get along.
      $log.debug 'parsed imported game successfully', ret
      # check save version for validity
      @_validateSaveVersion ret.version?.started
      # prevent saves imported from publictest. easy to hack around, but good enough to deter non-cheaters.
      if saveversion
        @_validateFormatVersion atob saveversion
      return @parseJson ret

    parseJson: (ret) ->
      for key, val of ret.date
        ret.date[key] = new Date val
      ret.date.loaded = new Date()
      # bigdecimals. toPrecision avoids decimal.js precision errors when converting old saves.
      for obj in [ret.unittypes, ret.upgrades]
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

    exportJson: ->
      return JSON.stringify @state

    importSave: (encoded, transient=true) ->
      @state = @_loads encoded
      @_exportCache = encoded
      if not transient
        @_write()
    
    _write: ->
      # write the game in @_exportCache without building a new one. usually
      # you'll want @save() instead, but @importSave() uses this to save the
      # game without overwriting its save-time.
      try
        storage.setItem @id, @_exportCache
        success = true
      catch e
        $log.error 'failed to save game', e
        $rootScope.$broadcast 'save:failed', {error:e, session:this}
      if success
        $rootScope.$broadcast 'save', this
    isLocalSaveEnabled: ->
      return not env.isServerFrontendEnabled
    save: ->
      if not @isLocalSaveEnabled()
        $log.warn 'local saves disabled'
        return
      # exportCache is necessary because sjcl encryption isn't deterministic,
      # but exportSave() must be ...not necessarily deterministic, but
      # consistent enough to not confuse angular's $apply().
      # Careful to delete it while saving, so saves don't contain other saves recursively!
      # TODO: refactor so it's in another object and we don't have to do this exclusion silliness
      delete @_exportCache
      @_exportCache = @_saves()
      @_write()
      $log.debug 'saving game (fresh export)'

    _setItem: (key, val) ->
      storage.setItem key, val

    getStoredSaveData: (id=@id) ->
      storage.getItem id

    load: (id) ->
      if not @isLocalSaveEnabled()
        $log.warn 'local saves disabled'
        return
      @importSave @getStoredSaveData id

    onClose: ->
      # Don't save the whole session - this avoids overwriting everything if the save failed to load.
      @onHeartbeat()

    onHeartbeat: ->
      if env.isOffline
        return false
      # periodically save the current date, in case onClose() doesn't fire.
      # give it its own localstorage slot, so it saves quicker (it's more frequent than other saves)
      # and generally doesn't screw with the rest of the session. It won't be exported; that's fine.
      try
        @_setItem @heartbeatId, new Date()
      catch e
        # No noisy error handling, heartbeats aren't critical.
        $log.warn "couldn't write heartbeat"

    _getHeartbeatDate: ->
      try
        if (heartbeat = storage.getItem @heartbeatId)
          return new Date heartbeat
      catch e
        $log.debug "Couldn't load heartbeat time to determine game-closed time. No biggie, continuing.", e
    dateClosed: (ignoreHeartbeat=false) ->
      # don't just use date.closed - maybe the browser crashed and it didn't fire. Use the latest date possible.
      closed = 0
      if (not ignoreHeartbeat) and (hb = @_getHeartbeatDate())
        closed = Math.max closed, hb.getTime()
      for key, date of @state.date
        if key != 'loaded' and key != 'saved'
          closed = Math.max closed, date.getTime()
      $log.debug 'dateclosed final', closed, key, new Date().getTime()-closed
      return new Date closed
    millisSinceClosed: (now=new Date(), ignoreHeartbeat) ->
      closed = @dateClosed ignoreHeartbeat
      ret = now.getTime() - closed.getTime()
      #$log.info {closed:closed, now:now.getTime(), diff:ret}
      return ret

    durationSinceClosed: (now, ignoreHeartbeat) ->
      ms = @millisSinceClosed now, ignoreHeartbeat
      return moment.duration ms, 'milliseconds'

angular.module('swarmApp').factory 'remoteSession', (storage, $rootScope, $log, util, version, env, saveId, isKongregate) ->
