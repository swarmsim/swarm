'use strict'

# remotesave iface:
# * isVisible()
# * init(fn) -> promise
# * fetch(fn) -> promise
# * fetchedSave() -> encoded save
# * pull()
# * push(fn) -> promise
# * clear(fn) -> promise
# * initAutopush(enabled=true)
# * autopush()
#
# TODO: refactor to actually use promises

angular.module('swarmApp').factory 'kongregateS3Syncer', ($log, kongregate, storage, game, env, $interval, $q, $rootScope) -> new class KongregateS3Syncer
  constructor: ->
    jQuery.ajaxSetup cached:false
  isVisible: ->
    env.isKongregateSyncEnabled and kongregate.isKongregate()
  init: (fn=(->), userid, token, force) ->
    # Fetch an S3 policy from our server. This allows S3 access without ever again calling our custom server.
    defer = $q.defer()
    ret = defer.promise
    # TODO refactor to use promises, remove callback
    ret.then fn, console.warn
    kongregate.onLoad.then =>
      @policy = null
      if force
        storage.removeItem 's3Policy'
      try
        policy = storage.getItem 's3Policy'
        if policy
          @policy = JSON.parse policy
          @cached = true
        else
          $log.debug 'no cached s3 policy', @policy
      catch e
        $log.warn "couldn't load cached s3 policy", e
      $log.debug 'cached policy', @policy
      if not @policy? or (expired=@policy.localDate?.expires < game.now.getTime())
        @cached = false
        $log.debug 'refreshing s3 policy', force, expired
        onRefresh = (data, status, xhr) =>
          if status == 'success'
            @policy = data
            $log.debug 'caching s3 policy', @policy
            storage.setItem 's3Policy', JSON.stringify @policy
          else
            $log.warn "couldn't refresh s3 policy", data, status
          @fetch (d) ->
            defer.resolve d
        return @_refreshPolicy onRefresh, userid, token
      else
        $log.debug 'cached s3 policy is good; not refreshing', @policy
        @fetch ->
          defer.resolve()
        return undefined
    kongregate.onLoad.catch (val) =>
      defer.reject val
    return ret

  isInit: ->
    return @policy?

  initAutopush: (enabled=true) ->
    if @autopushInterval
      $interval.cancel @autopushInterval
      @autopushInterval = null
    $(window).off 'unload', 'kongregate.autopush'
    if enabled
      @autopushInterval = $interval (=> @autopush()), env.autopushIntervalMs
      $(window).on 'unload', 'kongregate.autopush', =>
        $log.debug 'autopush unload'
        @autopush()

  _refreshPolicy: (fn=(->), userid, token) ->
    userid ?= kongregate.kongregate.services.getUserId()
    token ?= kongregate.kongregate.services.getGameAuthToken()
    args = policy: {user_id:userid, game_auth_token:token}
    xhr = $.post "#{env.saveServerUrl}/policies", args, (data, status, xhr) =>
      $log.debug 'refreshed s3 policy', data, status, xhr
      data.localDate =
        refreshed: game.now.getTime()
        expires: game.now.getTime() + data.expiresIn*1000
      fn data, status, xhr
    xhr.fail (data, status, xhr) ->
      $log.error 'refreshing s3 failed', data, status, xhr

  # sync operations named after git commands.
  # fetch: get a local copy we might import/pull, but don't actually import
  fetch: (fn=(->)) ->
    if !@policy.get
      throw new Error 'no policy. init() first.'
    xhr = $.get @policy.get, (data, status, xhr) =>
      $log.debug 'fetched from s3', data, status, xhr
      @fetched = data
      fn data, status, xhr
    xhr.fail (data, status, xhr) ->
      if data?.status == 404
        $log.debug 's3 fetch empty', data, status, xhr
      else
        $log.warn 's3 fetch failed', data, status, xhr

  fetchedSave: ->
    return @fetched?.encoded
  fetchedDate: ->
    if @fetched?.date?
      return new Date @fetched.date

  # pull: actually import, after fetching
  pull: ->
    save = @fetchedSave()
    if not save
      throw new Error 'nothing to pull'
    game.importSave save
    $rootScope.$broadcast 'import', {source:'kongregateS3Syncer', success:true}

  # push: export to remote. this is the tricky one; writes to s3.
  push: (fn=(->), encoded=game.session.exportSave()) ->
    if !@policy.post
      throw new Error 'no policy. init() first.'
    # post to S3. S3 requires a multipart post, which is not the default and is kind of a huge pain.
    # worth it overall, though.
    postbody = new FormData()
    for prop, val of @policy.post.params
      $log.debug 'form keyval', prop, val
      postbody.append prop, val
    pushed = encoded:encoded, date:game.now
    postbody.append 'file', new Blob [JSON.stringify pushed], {type: 'application/json'}
    # https://aws.amazon.com/articles/1434
    # https://stackoverflow.com/questions/5392344/sending-multipart-formdata-with-jquery-ajax
    $.ajax
      url: @policy.post.url
      data: postbody
      cache: false
      contentType: false
      processData: false
      type: 'POST'
      error: (data, status, xhr) =>
        $log.error 's3 post fail', data?.responseText, data, status, xhr
      success: (data, status, xhr) =>
        $log.debug 'exported to s3', data, status, xhr
        @fetched = pushed
        fn data, status, xhr
        # @fetch() # nope - S3 is eventually consistent, this might return old data

  getAutopushError: ->
    if @fetchedSave() == game.session.exportSave()
      return 'nochanges'
    if (@fetchedDate() ? new Date 0) > game.session.state.date.reified
      return 'remotenewer'
    # you'd think 'Date == Date' would work since >/</>=/<= work, but no, it's reference equality.
    if game.session.state.date.reified.getTime() == game.session.state.date.started.getTime()
      return 'newgame'
  autopush: ->
    if @isInit() and @autopushInterval
      if not @getAutopushError()
        $log.debug 'autopushing (with changes, for real)'
        @push()
      else
        $log.debug 'autopush triggered with no changes, ignoring'

  clear: (fn=(->)) ->
    if !@policy.delete
      throw new Error 'no policy. init() first.'
    $.ajax
      type: 'DELETE'
      url: @policy.delete
      error: (data, status, xhr) =>
        $log.error 's3 delete failed', data?.responseText, data, status, xhr
      success: (data, status, xhr) =>
        $log.debug 'cleared from s3', data, status, xhr
        delete @fetched
        fn data, status, xhr
        # @fetch() # nope - S3 is eventually consistent, this might return old data

angular.module('swarmApp').factory 'wwwPlayfabSyncer', ($log, env, game, $location, isKongregate, $interval, $rootScope, playfab) -> new class PlayfabSyncer
  isVisible: ->
    return env.playfabTitleId and not isKongregate()

  isAuth: ->
    return playfab.isAuthed()

  isInit: ->
    return @isAuth()

  init: (fn) ->
    playfab.autologin().then(fn, console.warn)

  # TODO share code with kongregate autosync
  initAutopush: (enabled=true) ->
    if @autopushInterval
      $interval.cancel @autopushInterval
      @autopushInterval = null
    $(window).off 'unload', 'playfab.autopush'
    if enabled
      $log.debug 'playfab autopush enabled'
      @autopushInterval = $interval (=> @autopush()), env.autopushIntervalMs
      $(window).on 'unload', 'playfab.autopush', =>
        $log.debug 'autopush unload'
        @autopush()

  fetch: (fn=(->)) ->
    playfab.fetch().then(fn, console.warn)

  fetchedSave: ->
    return playfab.auth?.state

  fetchedDate: ->
    return new Date(playfab.auth?.lastUpdated)

  push: (fn=(->)) ->
    playfab.push(game.session.exportSave()).then(fn, console.warn)

  getAutopushError: ->
    if @fetchedSave() == game.session.exportSave()
      return 'nochanges'
    # you'd think 'Date == Date' would work since >/</>=/<= work, but no, it's reference equality.
    if game.session.state.date.reified.getTime() == game.session.state.date.started.getTime()
      return 'newgame'

  # TODO share code with kong autosync
  autopush: ->
    if @isInit() and @autopushInterval
      if not @getAutopushError()
        $log.debug 'autopushing (with changes, for real)'
        @push()
      else
        $log.debug 'autopush triggered with no changes, ignoring'

  pull: ->
    save = @fetchedSave()
    if not save
      throw new Error 'nothing to pull'
    game.importSave save
    $rootScope.$broadcast 'import', {source:'wwwPlayfabSyncer', success:true}

  clear: (fn=(->)) ->
    playfab.clear().then(fn, console.warn)
