/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import jQuery from 'jquery';

// remotesave iface:
// * isVisible()
// * init(fn) -> promise
// * fetch(fn) -> promise
// * fetchedSave() -> encoded save
// * pull()
// * push(fn) -> promise
// * clear(fn) -> promise
// * initAutopush(enabled=true)
// * autopush()
//
// TODO: refactor to actually use promises

angular.module('swarmApp').factory('kongregateS3Syncer', function($log, kongregate, storage, game, env, $interval, $q, $rootScope) { let KongregateS3Syncer;
return new (KongregateS3Syncer = class KongregateS3Syncer {
  constructor() {
    jQuery.ajaxSetup({cached:false});
  }
  isVisible() { return false; }
  isActive() {
    return env.isKongregateSyncEnabled && kongregate.isKongregate();
  }
  init(fn, userid, token, force) {
    // Fetch an S3 policy from our server. This allows S3 access without ever again calling our custom server.
    if (fn == null) { fn = function() {}; }
    const defer = $q.defer();
    const ret = defer.promise;
    // TODO refactor to use promises, remove callback
    ret.then(fn, console.warn);
    kongregate.onLoad.then(() => {
      let expired, policy;
      this.policy = null;
      if (force) {
        storage.removeItem('s3Policy');
      }
      try {
        policy = storage.getItem('s3Policy');
        if (policy) {
          this.policy = JSON.parse(policy);
          this.cached = true;
        } else {
          $log.debug('no cached s3 policy', this.policy);
        }
      } catch (e) {
        $log.warn("couldn't load cached s3 policy", e);
      }
      $log.debug('cached policy', this.policy);
      if ((this.policy == null) || (expired=(this.policy.localDate != null ? this.policy.localDate.expires : undefined) < game.now.getTime())) {
        this.cached = false;
        $log.debug('refreshing s3 policy', force, expired);
        const onRefresh = (data, status, xhr) => {
          if (status === 'success') {
            this.policy = data;
            $log.debug('caching s3 policy', this.policy);
            storage.setItem('s3Policy', JSON.stringify(this.policy));
          } else {
            $log.warn("couldn't refresh s3 policy", data, status);
          }
          return this.fetch(d => defer.resolve(d));
        };
        return this._refreshPolicy(onRefresh, userid, token);
      } else {
        $log.debug('cached s3 policy is good; not refreshing', this.policy);
        this.fetch(() => defer.resolve());
        return undefined;
      }
    });
    kongregate.onLoad.catch(val => {
      return defer.reject(val);
    });
    return ret;
  }

  isInit() {
    return (this.policy != null);
  }

  initAutopush(enabled) {
    if (enabled == null) { enabled = true; }
    if (this.autopushInterval) {
      $interval.cancel(this.autopushInterval);
      this.autopushInterval = null;
    }
    $(window).off('unload', 'kongregate.autopush');
    if (enabled) {
      this.autopushInterval = $interval((() => this.autopush()), env.autopushIntervalMs);
      return $(window).on('unload', 'kongregate.autopush', () => {
        $log.debug('autopush unload');
        return this.autopush();
      });
    }
  }

  _refreshPolicy(fn, userid, token) {
    if (fn == null) { fn = function() {}; }
    if (userid == null) { userid = kongregate.kongregate.services.getUserId(); }
    if (token == null) { token = kongregate.kongregate.services.getGameAuthToken(); }
    const args = {policy: {user_id:userid, game_auth_token:token}};
    const xhr = $.post(`${env.saveServerUrl}/policies`, args, (data, status, xhr) => {
      $log.debug('refreshed s3 policy', data, status, xhr);
      data.localDate = {
        refreshed: game.now.getTime(),
        expires: game.now.getTime() + (data.expiresIn*1000)
      };
      return fn(data, status, xhr);
    });
    return xhr.fail((data, status, xhr) => $log.error('refreshing s3 failed', data, status, xhr));
  }

  // sync operations named after git commands.
  // fetch: get a local copy we might import/pull, but don't actually import
  fetch(fn) {
    if (fn == null) { fn = function() {}; }
    if (!this.policy.get) {
      throw new Error('no policy. init() first.');
    }
    const xhr = $.get(this.policy.get, (data, status, xhr) => {
      $log.debug('fetched from s3', data, status, xhr);
      this.fetched = data;
      return fn(data, status, xhr);
    });
    return xhr.fail(function(data, status, xhr) {
      if ((data != null ? data.status : undefined) === 404) {
        return $log.debug('s3 fetch empty', data, status, xhr);
      } else {
        return $log.warn('s3 fetch failed', data, status, xhr);
      }
    });
  }

  fetchedSave() {
    return (this.fetched != null ? this.fetched.encoded : undefined);
  }
  fetchedDate() {
    if ((this.fetched != null ? this.fetched.date : undefined) != null) {
      return new Date(this.fetched.date);
    }
  }

  // pull: actually import, after fetching
  pull() {
    const save = this.fetchedSave();
    if (!save) {
      throw new Error('nothing to pull');
    }
    game.importSave(save);
    return $rootScope.$broadcast('import', {source:'kongregateS3Syncer', success:true});
  }

  // push: export to remote. this is the tricky one; writes to s3.
  push(fn, encoded) {
    if (fn == null) { fn = function() {}; }
    if (encoded == null) { encoded = game.session.exportSave(); }
    if (!this.policy.post) {
      throw new Error('no policy. init() first.');
    }
    // post to S3. S3 requires a multipart post, which is not the default and is kind of a huge pain.
    // worth it overall, though.
    const postbody = new FormData();
    for (var prop in this.policy.post.params) {
      var val = this.policy.post.params[prop];
      $log.debug('form keyval', prop, val);
      postbody.append(prop, val);
    }
    const pushed = {encoded, date:game.now};
    postbody.append('file', new Blob([JSON.stringify(pushed)], {type: 'application/json'}));
    // https://aws.amazon.com/articles/1434
    // https://stackoverflow.com/questions/5392344/sending-multipart-formdata-with-jquery-ajax
    return $.ajax({
      url: this.policy.post.url,
      data: postbody,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      error: (data, status, xhr) => {
        return $log.error('s3 post fail', data != null ? data.responseText : undefined, data, status, xhr);
      },
      success: (data, status, xhr) => {
        $log.debug('exported to s3', data, status, xhr);
        this.fetched = pushed;
        return fn(data, status, xhr);
      }
    });
  }
        // @fetch() # nope - S3 is eventually consistent, this might return old data

  getAutopushError() {
    let left;
    if (this.fetchedSave() === game.session.exportSave()) {
      return 'nochanges';
    }
    if (((left = this.fetchedDate()) != null ? left : new Date(0)) > game.session.state.date.reified) {
      return 'remotenewer';
    }
    // you'd think 'Date == Date' would work since >/</>=/<= work, but no, it's reference equality.
    if (game.session.state.date.reified.getTime() === game.session.state.date.started.getTime()) {
      return 'newgame';
    }
  }
  autopush() {
    if (this.isInit() && this.autopushInterval) {
      if (!this.getAutopushError()) {
        $log.debug('autopushing (with changes, for real)');
        return this.push();
      } else {
        return $log.debug('autopush triggered with no changes, ignoring');
      }
    }
  }

  clear(fn) {
    if (fn == null) { fn = function() {}; }
    if (!this.policy.delete) {
      throw new Error('no policy. init() first.');
    }
    return $.ajax({
      type: 'DELETE',
      url: this.policy.delete,
      error: (data, status, xhr) => {
        return $log.error('s3 delete failed', data != null ? data.responseText : undefined, data, status, xhr);
      },
      success: (data, status, xhr) => {
        $log.debug('cleared from s3', data, status, xhr);
        delete this.fetched;
        return fn(data, status, xhr);
      }
    });
  }
});
 });
        // @fetch() # nope - S3 is eventually consistent, this might return old data


angular.module('swarmApp').factory('syncerUtil', function($log, env, game, isKongregate, $interval, $rootScope, playfab) { let SyncerUtil;
return new (SyncerUtil = class SyncerUtil {
  initAutopush(name, enabled) {
    if (enabled == null) { enabled = true; }
    if (this.autopushInterval) {
      $interval.cancel(this.autopushInterval);
      this.autopushInterval = null;
    }
    $(window).off('unload', `${name}.autopush`);
    if (enabled) {
      $log.debug(`${name} autopush enabled`);
      this.autopushInterval = $interval((() => this.autopush()), env.autopushIntervalMs);
      return $(window).on('unload', `${name}.autopush`, () => {
        $log.debug(`${name} autopush unload`);
        return this.autopush();
      });
    }
  }
});
 });


// the syncer for kongregate (currently silent, will eventually replace s3)
angular.module('swarmApp').factory('kongregatePlayfabSyncer', function($log, env, game, kongregate, $interval, $rootScope, playfab, syncerUtil) { let KongregatePlayfabSyncer;
return new (KongregatePlayfabSyncer = class KongregatePlayfabSyncer {
  isVisible() {
    return env.playfabTitleId && env.isKongregateSyncEnabled && kongregate.isKongregate();
  }

  isAuth() {
    return playfab.isAuthed();
  }

  isInit() {
    return this.isAuth();
  }

  init(fn) {
    return kongregate.onLoad.then(
      () => {
        const userid = window.parent.kongregate.services.getUserId();
        const token = window.parent.kongregate.services.getGameAuthToken();
        return playfab.kongregateLogin(userid, token).then(fn, console.warn);
      },
      console.warn);
  }

  initAutopush(enabled) {
    return syncerUtil.initAutopush.call(this, 'kongregatePlayfab', enabled);
  }

  fetch(fn) {
    if (fn == null) { fn = res => res; }
    return playfab.fetch().then(fn, console.warn);
  }

  fetchedSave() {
    return (playfab.auth != null ? playfab.auth.state : undefined);
  }

  fetchedDate() {
    return new Date(playfab.auth != null ? playfab.auth.lastUpdated : undefined);
  }

  push(fn) {
    if (fn == null) { fn = function() {}; }
    return playfab.push(game.session.exportSave()).then(fn, console.warn);
  }

  getAutopushError() {
    if (this.fetchedSave() === game.session.exportSave()) {
      return 'nochanges';
    }
    // you'd think 'Date == Date' would work since >/</>=/<= work, but no, it's reference equality.
    if (game.session.state.date.reified.getTime() === game.session.state.date.started.getTime()) {
      return 'newgame';
    }
  }

  // TODO share code with kong autosync
  autopush() {
    if (this.isInit() && this.autopushInterval) {
      if (!this.getAutopushError()) {
        $log.debug('autopushing (with changes, for real)');
        return this.push();
      } else {
        return $log.debug('autopush triggered with no changes, ignoring');
      }
    }
  }

  pull() {
    const save = this.fetchedSave();
    if (!save) {
      throw new Error('nothing to pull');
    }
    game.importSave(save);
    return $rootScope.$broadcast('import', {source:'kongregatePlayfabSyncer', success:true});
  }

  clear(fn) {
    if (fn == null) { fn = function() {}; }
    return playfab.clear().then(fn, console.warn);
  }
});
 });


// the syncer for swarmsim.github.io
angular.module('swarmApp').factory('wwwPlayfabSyncer', function($log, env, game, $location, isKongregate, $interval, $rootScope, playfab, syncerUtil) { let PlayfabSyncer;
return new (PlayfabSyncer = class PlayfabSyncer {
  isVisible() {
    return env.playfabTitleId && !isKongregate();
  }

  isAuth() {
    return playfab.isAuthed();
  }

  isInit() {
    return this.isAuth();
  }

  init(fn) {
    return playfab.autologin().then(fn, console.warn);
  }

  initAutopush(enabled) {
    if (enabled == null) { enabled = true; }
    return syncerUtil.initAutopush.call(this, 'wwwPlayfab', enabled);
  }

  fetch(fn) {
    if (fn == null) { fn = function() {}; }
    return playfab.fetch().then(fn, console.warn);
  }

  fetchedSave() {
    return (playfab.auth != null ? playfab.auth.state : undefined);
  }

  fetchedDate() {
    return new Date(playfab.auth != null ? playfab.auth.lastUpdated : undefined);
  }

  push(fn) {
    if (fn == null) { fn = function() {}; }
    return playfab.push(game.session.exportSave()).then(fn, console.warn);
  }

  getAutopushError() {
    if (this.fetchedSave() === game.session.exportSave()) {
      return 'nochanges';
    }
    // you'd think 'Date == Date' would work since >/</>=/<= work, but no, it's reference equality.
    if (game.session.state.date.reified.getTime() === game.session.state.date.started.getTime()) {
      return 'newgame';
    }
  }

  // TODO share code with kong autosync
  autopush() {
    if (this.isInit() && this.autopushInterval) {
      if (!this.getAutopushError()) {
        $log.debug('autopushing (with changes, for real)');
        return this.push();
      } else {
        return $log.debug('autopush triggered with no changes, ignoring');
      }
    }
  }

  pull() {
    const save = this.fetchedSave();
    if (!save) {
      throw new Error('nothing to pull');
    }
    game.importSave(save);
    return $rootScope.$broadcast('import', {source:'wwwPlayfabSyncer', success:true});
  }

  clear(fn) {
    if (fn == null) { fn = function() {}; }
    return playfab.clear().then(fn, console.warn);
  }
});
 });
