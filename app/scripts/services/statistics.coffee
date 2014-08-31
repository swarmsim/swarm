'use strict'

angular.module('swarmApp').factory 'ReplayLog', (util, $rootScope, env) -> class ReplayLog
  constructor: (@id, @log=[]) ->
    @_init()
  _init: ->
    @tryLoad()
  push: (cmd) ->
    @log.push cmd
    @_cachedSave = @save()
    console.log 'saving replay', @_cachedSave.length
    $rootScope.$emit 'replay:save', this
  reset: ->
    @log.length = 0
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
    localStorage.setItem "replay:#{@id}", encoded
    return encoded

  load: ->
    encoded = localStorage.getItem "replay:#{@id}"
    encoded = LZString.decompressFromUTF16 encoded
    @log = JSON.parse encoded

  tryLoad: ->
    try
      @load()
    catch e
      if env != 'test'
        console.warn "couldn't load replay log, ignoring.", e

###*
 # @ngdoc service
 # @name swarmApp.statistics
 # @description
 # # statistics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'StatisticsListener', (util, ReplayLog) -> class StatisticsListener
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
      if not stats.byUnit[cmd.unitname]?
        @scope.$emit 'buyFirst', cmd
      ustats = stats.byUnit[cmd.unitname] ?= {clicks:0,num:0,twinnum:0,elapsedFirst:cmd.elapsed}
      ustats.clicks += 1
      ustats.num += cmd.num
      ustats.twinnum += cmd.twinnum
    if cmd.upgradename?
      if not stats.byUpgrade[cmd.unitname]?
        @scope.$emit 'buyFirst', cmd
      ustats = stats.byUpgrade[cmd.upgradename] ?= {clicks:0,num:0,elapsedFirst:cmd.elapsed}
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
      #console.log 'statistics', event, cmd
      @push cmd

angular.module('swarmApp').factory 'statistics', (session, StatisticsListener, $rootScope) ->
  stats = new StatisticsListener session, $rootScope
  stats.listen $rootScope
  return stats
