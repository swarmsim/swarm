'use strict'

angular.module('swarmApp').factory 'ReplayLog', ($log, util, $rootScope) -> class ReplayLog
  constructor: (@id, @log=[]) ->
    @_init()
  _init: ->
    @tryLoad()
  push: (cmd) ->
    @log.push cmd
    @_cachedSave = @save()
    $log.debug 'saving replay', @_cachedSave.length
    $rootScope.$emit 'replay:save', this
    # avoid memory leak while dry-running this
    if @log.length > 100
      @reset()
  reset: ->
    while @log.length > 0 then @log.pop()
    @save()

  compressToUTF16: ->
    LZString.compressToUTF16 JSON.stringify @log
  compressToBase64: ->
    LZString.compressToBase64 JSON.stringify @log

  # why not save this with the session? Because I'm worried it'll get really
  # big, too big for localstorage, and it's not nearly important enough to hose
  # the rest of the save state. Also, since it's bigger, we compress it more
  # carefully.
  save: ->
    encoded = JSON.stringify @log
    encoded = LZString.compressToUTF16 encoded
    key = "replay:#{@id}"
    # Disabled click log storage. https://github.com/erosson/swarm/issues/58
    #localStorage.setItem key, encoded
    return encoded

  load: ->
    # Disabled click log storage. https://github.com/erosson/swarm/issues/58
    localStorage.removeItem "replay:#{@id}"
    #encoded = localStorage.getItem "replay:#{@id}"
    #if encoded
    #  encoded = LZString.decompressFromUTF16 encoded
    #  @log = JSON.parse encoded

  tryLoad: ->
    try
      @load()
    catch e
      $log.debug "couldn't load replay log, ignoring.", e

###*
 # @ngdoc service
 # @name swarmApp.statistics
 # @description
 # # statistics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'StatisticsListener', (util, ReplayLog, $log) -> class StatisticsListener
  constructor: (@session, @scope) ->
    # Transient. TODO: persist this separately from session, it can get big
    @replay = new ReplayLog session.id
    @_init()

  _init: ->
    stats = @session.statistics ?= {}
    stats.byUnit ?= {}
    stats.byUpgrade ?= {}
    stats.clicks ?= 0
    @replay.tryLoad()
  
  push: (cmd) ->
    stats = @session.statistics
    stats.clicks += 1
    if cmd.unitname?
      ustats = stats.byUnit[cmd.unitname]
      if not ustats?
        ustats = stats.byUnit[cmd.unitname] = {clicks:0,num:0,twinnum:0,elapsedFirst:cmd.elapsed}
        @scope.$emit 'buyFirst', cmd
      ustats.clicks += 1
      ustats.num += cmd.num
      ustats.twinnum += cmd.twinnum
    if cmd.upgradename?
      ustats = stats.byUpgrade[cmd.upgradename]
      if not ustats?
        ustats = stats.byUpgrade[cmd.upgradename] = {clicks:0,num:0,elapsedFirst:cmd.elapsed}
        @scope.$emit 'buyFirst', cmd
      ustats.clicks += 1
      ustats.num += cmd.num
    @session.save() #TODO session is saved twice for every command, kind of lame
    delete cmd.now
    delete cmd.unit
    delete cmd.upgrade
    @replay.push cmd

  listen: (scope) ->
    scope.$on 'reset', =>
      @_init()
      @replay.reset()
    scope.$on 'command', (event, cmd) =>
      $log.debug 'statistics', event, cmd
      @push cmd

angular.module('swarmApp').factory 'statistics', (session, StatisticsListener, $rootScope) ->
  stats = new StatisticsListener session, $rootScope
  stats.listen $rootScope
  return stats
