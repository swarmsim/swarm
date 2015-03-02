'use strict'

# All storage implementations here have an API similar to dom storage/localstorage:
# https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#Storage

# Cookie storage has a smaller max size than localstorage in some browsers,
# but lets us easily communicate between http and https
# https://github.com/carhartl/jquery-cookie/tree/v1.4.1
angular.module('swarmApp').factory 'cookieStorage', -> new class CookieStorage
  getItem: (key) ->
    $.cookie key
  setItem: (key, val) ->
    # expiration date is required, 100 years oughta be enough
    $.cookie key, val, expires:36500, secure:false
  removeItem: (key) ->
    $.removeCookie key

# Flash storage won't work on mobile or browsers with plugins blocked, but will
# work on desktops with third-party cookies blocked. This is important for
# Kongregate users, who probably have flash persistence configured correctly.
# https://github.com/nfriedly/Javascript-Flash-Cookies
angular.module('swarmApp').factory 'flashStorage', ($q, $log, env) -> new class FlashStorage
  constructor: ->
    # https://docs.angularjs.org/api/ng/service/$q
    deferred = $q.defer()
    @onReady = deferred.promise
    try
      @storage = new SwfStore
        namespace: "swarmsim"
        swf_url: "./storage.swf"
        timeout: 10,
        onready: =>
          @isReady ?= true
          deferred.resolve()
          $log.debug 'flash storage ready'
        onerror: =>
          @isReady = false
          deferred.reject()
          $log.warn 'flash storage error'
    catch e
      @isReady = false
      deferred.reject()
      $log.warn 'flash storage init error'
  getItem: (key) ->
    @storage.get key
  setItem: (key, val) ->
    @storage.set key, val
  removeItem: (key) ->
    @storage.clear key
  clear: ->
    @storage.clearAll()

angular.module('swarmApp').factory 'MultiStorage', ($log) -> class MultiStorage
  constructor: ->
    @storages =
      list: []
      byName: {}
  addStorage: (name, storage) ->
    obj = {name:name, storage:storage}
    @storages.list.push obj
    @storages.byName[name] = obj
    this[name] = storage
    return this

  _withEachStore: (name, fn, pred=(ret)->false) ->
    errorcount = 0
    for store in @storages.list
      try
        ret = fn store
        if pred ret
          return ret
      catch e
        errorcount += 1
        if errorcount >= @storages.list.length
          $log.warn "multistore.#{name} failed with all stores, throwing", e
          throw e
        else
          $log.info "multistore.#{name} error (continuing)", store.name, e
    return undefined

  getItem: (key) ->
    # Go through the storage list and return the first one that's not empty.
    # Storage order in the ctor matters, earlier storages are higher priority.
    fn = (store) ->
      $log.debug 'multistore.getitem', store.name
      return store.storage.getItem key
    return @_withEachStore 'getItem', fn, (ret) -> ret?
  setItem: (key, val) ->
    # Set all storages.
    return @_withEachStore 'setItem', (store) ->
      $log.debug 'multistore.setitem', store.name, key
      store.storage.setItem key, val
  removeItem: (key) ->
    # Set all storages.
    return @_withEachStore 'removeItem', (store) ->
      $log.debug 'multistore.removeitem', store.name, key
      store.storage.removeItem key
  toJSON: ->
    return undefined

angular.module('swarmApp').factory 'storage', (MultiStorage, flashStorage, cookieStorage) ->
  return new MultiStorage()
    .addStorage 'local', window.localStorage
    .addStorage 'cookie', cookieStorage
    .addStorage 'flash', flashStorage
