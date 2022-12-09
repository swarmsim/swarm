/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import $ from 'jquery';
import '@bower_components/jquery-cookie';

// All storage implementations here have an API similar to dom storage/localstorage:
// https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#Storage

// Cookie storage has a smaller max size than localstorage in some browsers,
// but lets us easily communicate between http and https
// https://github.com/carhartl/jquery-cookie/tree/v1.4.1
angular.module('swarmApp').factory('cookieStorage', function() { let CookieStorage;
return new (CookieStorage = class CookieStorage {
  getItem(key) {
    return $.cookie(key);
  }
  setItem(key, val) {
    // expiration date is required, 100 years oughta be enough
    return $.cookie(key, val, {expires:36500, secure:false});
  }
  removeItem(key) {
    return $.removeCookie(key);
  }
});
 });

//# Flash storage won't work on mobile or browsers with plugins blocked, but will
//# work on desktops with third-party cookies blocked. This is important for
//# Kongregate users, who probably have flash persistence configured correctly.
//# https://github.com/nfriedly/Javascript-Flash-Cookies
//angular.module('swarmApp').factory 'flashStorage', ($q, $log, env) -> new class FlashStorage
//  constructor: ->
//    # https://docs.angularjs.org/api/ng/service/$q
//    deferred = $q.defer()
//    @onReady = deferred.promise
//    try
//      @storage = new SwfStore
//        namespace: "swarmsim"
//        swf_url: "./storage.swf"
//        timeout: 10,
//        onready: =>
//          @isReady ?= true
//          deferred.resolve()
//          $log.debug 'flash storage ready'
//        onerror: =>
//          @isReady = false
//          deferred.reject()
//          $log.warn 'flash storage error'
//    catch e
//      @isReady = false
//      deferred.reject()
//      $log.warn 'flash storage init error'
//  getItem: (key) ->
//    @storage.get key
//  setItem: (key, val) ->
//    @storage.set key, val
//  removeItem: (key) ->
//    @storage.clear key
//  clear: ->
//    @storage.clearAll()

angular.module('swarmApp').factory('MultiStorage', function($log) { let MultiStorage;
return MultiStorage = class MultiStorage {
  constructor() {
    this.storages = {
      list: [],
      byName: {}
    };
  }
  addStorage(name, storage) {
    const obj = {name, storage};
    this.storages.list.push(obj);
    this.storages.byName[name] = obj;
    this[name] = storage;
    return this;
  }

  _withEachStore(name, fn, pred) {
    if (pred == null) { pred = ret => false; }
    let errorcount = 0;
    for (var store of Array.from(this.storages.list)) {
      try {
        var ret = fn(store);
        if (pred(ret)) {
          return ret;
        }
      } catch (e) {
        errorcount += 1;
        if (errorcount >= this.storages.list.length) {
          $log.warn(`multistore.${name} failed with all stores, throwing`, e);
          throw e;
        } else {
          $log.info(`multistore.${name} error (continuing)`, store.name, e);
        }
      }
    }
    return undefined;
  }

  getItem(key) {
    // Go through the storage list and return the first one that's not empty.
    // Storage order in the ctor matters, earlier storages are higher priority.
    const fn = function(store) {
      $log.debug('multistore.getitem', store.name);
      return store.storage.getItem(key);
    };
    return this._withEachStore('getItem', fn, ret => ret != null);
  }
  setItem(key, val) {
    // Set all storages.
    return this._withEachStore('setItem', function(store) {
      $log.debug('multistore.setitem', store.name, key);
      return store.storage.setItem(key, val);
    });
  }
  removeItem(key) {
    // Set all storages.
    return this._withEachStore('removeItem', function(store) {
      $log.debug('multistore.removeitem', store.name, key);
      return store.storage.removeItem(key);
    });
  }
  toJSON() {
    return undefined;
  }
};
 });

// angular.module('swarmApp').factory 'storage', (MultiStorage, flashStorage, cookieStorage) ->
angular.module('swarmApp').factory('storage', (MultiStorage, cookieStorage) => new MultiStorage()
  .addStorage('local', window.localStorage)
  .addStorage('cookie', cookieStorage));
    // .addStorage 'flash', flashStorage
