/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';
import {Decimal} from 'decimal.js';
// import * as moment from '@bower_components/moment'
import LZString from '@bower_components/lz-string';

angular.module('swarmApp').factory('saveId', function(env, isKongregate) {
  const suffix = isKongregate() ? '-kongregate' : '';
  return `${env.saveId}${suffix}`;
});

/**
 * @ngdoc service
 * @name swarmApp.session
 * @description
 * # session
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('session', function(storage, $rootScope, $log, util, version, env, saveId, isKongregate) {
  let Session;
  const PREFIX = btoa("Cheater :(\n\n");
  // The encoded string starts with an encoded version number. Older savestates
  // might not, so if this is missing, no biggie.
  const VERSION_DELIM = '|';

  return new (Session = class Session {
    constructor() {
      this.reset();
      $log.debug('save id', this.id);
      util.assert(this.id, 'no save id defined');
    }

    reset() {
      const now = new Date();
      this.id = saveId;
      this.heartbeatId = `${this.id}:heartbeat`;
      this.state = {
        unittypes: {},
        date: {
          started: now,
          restarted: now,
          saved: now,
          loaded: now,
          reified: now,
          closed: now
        },
        options: {},
        upgrades: {},
        statistics: {},
        achievements: {},
        watched: {},
        skippedMillis: 0,
        version: {
          started: version,
          saved: version
        }
      };
      // undefined if not isKongregate
      if (isKongregate()) {
        this.state.kongregate = true;
      }
      return $rootScope.$broadcast('reset', {session:this});
    }

    _saves(data, setdates) {
      if (data == null) { data = this.state; }
      if (setdates == null) { setdates = true; }
      if (setdates) {
        data.date.saved = new Date();
        delete data.date.loaded;
        if (data.version != null) {
          data.version.saved = version;
        }
      }
      let ret = JSON.stringify(data);
      ret = LZString.compressToBase64(ret);
      //ret = LZString.compressToUTF16 ret
      //ret = sjcl.encrypt KEY, ret
      ret = PREFIX + ret;
      // version is saved separately from json in case save format changes
      ret = `${btoa(version)}${VERSION_DELIM}${ret}`;
      //ret = btoa ret
      return ret;
    }
    _hasVersionHeader(encoded) {
      return encoded.indexOf(VERSION_DELIM) >= 0;
    }
    _splitVersionHeader(encoded) {
      let saveversion;
      if (this._hasVersionHeader(encoded)) {
        [saveversion, encoded] = Array.from(encoded.split(VERSION_DELIM));
      }
      // version may be undefined
      return [saveversion, encoded];
    }
    _validateSaveVersion(saveversion, gameversion) {
      if (saveversion == null) { saveversion = '0.1.0'; }
      if (gameversion == null) { gameversion = version; }
      const [sM, sm, sp] = Array.from(saveversion.split('.').map(n => parseInt(n)));
      const [gM, gm, gp] = Array.from(gameversion.split('.').map(n => parseInt(n)));
      // during beta, 0.n.0 resets all games from 0.n-1.x. Don't import older games.
      if ((sM === gM && gM === 0) && (sm !== gm)) {
        throw new Error('Beta save from different minor version');
      }
      // No importing 1.0.x games into 0.2.x. Need this for publictest.
      // Importing 0.2.x into 1.0.x is fine.
      // Keep in mind - 0.2.x might not be running this code, but older code that resets at 1.0. (Should make no difference.)
      if ((sM > 0) && (gM === 0)) {
        throw new Error('1.0 save in 0.x game');
      }
      // 0.1.x saves are blacklisted for 1.0.x, already reset
      if ((gM > 0) && (sM === 0) && (sm < 2)) {
        throw new Error('nice try, no 0.1.x saves');
      }
      //# save state must not be newer than the game running it
      //# actually, let's allow this. support for fast rollbacks is more important.
      //if sM > gM or (sM == gM and (sm > gm or (sm == gm and sp > gp)))
      //  throw new Error "save version newer than game version: #{saveversion} > #{gameversion}"

      // coffeescript: two-dot range is inclusive
      const blacklisted = [/^1\.0\.0-publictest/];
      // never blacklist the current version; also makes tests pass before we do `npm version 1.0.0`
      if (saveversion !== gameversion) {
        return (() => {
          const result = [];
          for (var b of Array.from(blacklisted)) {
            if (b.test(saveversion)) {
              throw new Error('blacklisted save version');
            } else {
              result.push(undefined);
            }
          }
          return result;
        })();
      }
    }

    _validateFormatVersion(formatversion, gameversion) {
      // coffeescript: two-dot range is inclusive
      if (gameversion == null) { gameversion = version; }
      const blacklisted = [/^1\.0\.0-publictest/];
      // never blacklist the current version; also makes tests pass before we do `npm version 1.0.0`
      if (formatversion !== gameversion) {
        return (() => {
          const result = [];
          for (var b of Array.from(blacklisted)) {
            if (b.test(formatversion)) {
              throw new Error('blacklisted save version');
            } else {
              result.push(undefined);
            }
          }
          return result;
        })();
      }
    }

    _loads(encoded) {
      // ignore whitespace
      let key, saveversion, val;
      encoded = encoded.replace(/\s+/g, '');
      $log.debug('decoding imported game. len', encoded != null ? encoded.length : undefined);
      //encoded = atob encoded
      [saveversion, encoded] = Array.from(this._splitVersionHeader(encoded));
      // don't compare this saveversion for validity! it's only for figuring out changing save formats.
      // (with some exceptions, like publictest.)
      encoded = encoded.substring(PREFIX.length);
      //encoded = sjcl.decrypt KEY, encoded
      //encoded = LZString.decompressFromUTF16 encoded
      encoded = LZString.decompressFromBase64(encoded);
      $log.debug('decompressed imported game successfully', [encoded]);
      const ret = JSON.parse(encoded);
      // special case dates. JSON.stringify replacers and toJSON do not get along.
      $log.debug('parsed imported game successfully', ret);
      for (key in ret.date) {
        val = ret.date[key];
        ret.date[key] = new Date(val);
      }
      ret.date.loaded = new Date();
      // check save version for validity
      this._validateSaveVersion(ret.version != null ? ret.version.started : undefined);
      // prevent saves imported from publictest. easy to hack around, but good enough to deter non-cheaters.
      if (saveversion) {
        this._validateFormatVersion(atob(saveversion));
      }
      // bigdecimals. toPrecision avoids decimal.js precision errors when converting old saves.
      for (var obj of [ret.unittypes, ret.upgrades]) {
        for (key in obj) {
          val = obj[key];
          if (_.isNumber(val)) {
            val = val.toPrecision(15);
          }
          obj[key] = new Decimal(val);
        }
      }
      return ret;
    }

    exportSave() {
      if ((this._exportCache == null)) {
        // this happens on page load, when we haven't saved
        this._exportCache = this._saves(undefined, false);
      }
      return this._exportCache;
    }

    exportJson() {
      return JSON.stringify(this.state);
    }

    importSave(encoded, transient) {
      if (transient == null) { transient = true; }
      this.state = this._loads(encoded);
      this._exportCache = encoded;
      if (!transient) {
        return this._write();
      }
    }

    _write() {
      // write the game in @_exportCache without building a new one. usually
      // you'll want @save() instead, but @importSave() uses this to save the
      // game without overwriting its save-time.
      let success;
      try {
        storage.setItem(this.id, this._exportCache);
        success = true;
      } catch (e) {
        $log.error('failed to save game', e);
        $rootScope.$broadcast('save:failed', {error:e, session:this});
      }
      if (success) {
        return $rootScope.$broadcast('save', this);
      }
    }
    save() {
      if (env.isOffline) {
        $log.warn('cannot save, game is offline');
      }
      // exportCache is necessary because sjcl encryption isn't deterministic,
      // but exportSave() must be ...not necessarily deterministic, but
      // consistent enough to not confuse angular's $apply().
      // Careful to delete it while saving, so saves don't contain other saves recursively!
      // TODO: refactor so it's in another object and we don't have to do this exclusion silliness
      delete this._exportCache;
      this._exportCache = this._saves();
      this._write();
      return $log.debug('saving game (fresh export)');
    }

    _setItem(key, val) {
      return storage.setItem(key, val);
    }

    getStoredSaveData(id) {
      if (id == null) { ({
        id
      } = this); }
      return storage.getItem(id);
    }

    load(id) {
      return this.importSave(this.getStoredSaveData(id));
    }

    onClose() {
      // Don't save the whole session - this avoids overwriting everything if the save failed to load.
      return this.onHeartbeat();
    }

    onHeartbeat() {
      if (env.isOffline) {
        return false;
      }
      // periodically save the current date, in case onClose() doesn't fire.
      // give it its own localstorage slot, so it saves quicker (it's more frequent than other saves)
      // and generally doesn't screw with the rest of the session. It won't be exported; that's fine.
      try {
        return this._setItem(this.heartbeatId, new Date());
      } catch (e) {
        // No noisy error handling, heartbeats aren't critical.
        return $log.warn("couldn't write heartbeat");
      }
    }

    _getHeartbeatDate() {
      try {
        let heartbeat;
        if (heartbeat = storage.getItem(this.heartbeatId)) {
          return new Date(heartbeat);
        }
      } catch (e) {
        return $log.debug("Couldn't load heartbeat time to determine game-closed time. No biggie, continuing.", e);
      }
    }
    dateClosed(ignoreHeartbeat) {
      // don't just use date.closed - maybe the browser crashed and it didn't fire. Use the latest date possible.
      let hb, key;
      if (ignoreHeartbeat == null) { ignoreHeartbeat = false; }
      let closed = 0;
      if ((!ignoreHeartbeat) && (hb = this._getHeartbeatDate())) {
        closed = Math.max(closed, hb.getTime());
      }
      for (key in this.state.date) {
        var date = this.state.date[key];
        if ((key !== 'loaded') && (key !== 'saved')) {
          closed = Math.max(closed, date.getTime());
        }
      }
      $log.debug('dateclosed final', closed, key, new Date().getTime()-closed);
      return new Date(closed);
    }
    millisSinceClosed(now, ignoreHeartbeat) {
      if (now == null) { now = new Date(); }
      const closed = this.dateClosed(ignoreHeartbeat);
      const ret = now.getTime() - closed.getTime();
      //$log.info {closed:closed, now:now.getTime(), diff:ret}
      return ret;
    }

    durationSinceClosed(now, ignoreHeartbeat) {
      const ms = this.millisSinceClosed(now, ignoreHeartbeat);
      return moment.duration(ms, 'milliseconds');
    }
  });
});
