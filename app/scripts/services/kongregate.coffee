'use strict'

###*
 # @ngdoc service
 # @name swarmApp.Kongregate
 # @description
 # # Kongregate
 # Service in the swarmApp.
 #
 # http://developers.kongregate.com/docs/api-overview/client-api
###
angular.module('swarmApp').factory 'isKongregate', ->
  return ->
    # use the non-# querystring to avoid losing it when the url changes. $location.search() won't work.
    # a simple string-contains is hacky, but good enough as long as we're not using the querystring for anything else.
    _.contains window.location.search, 'kongregate'
    # alternatives:
    # - #-querystring is overwritten on reload.
    # - url is hard to test, and flaky with proxies.
    # - separate deployment? functional, but ugly maintenance.
    # - when-framed-assume-kongregate? could work...
    # - hard-querystring (/?kongregate#/tab/meat) seems to work well! can't figure out how to get out of it in 30sec.

angular.module('swarmApp').factory 'Kongregate', (isKongregate, $log, $location, game) -> class Kongregate
  constructor: ->
  isKongregate: ->
    isKongregate()
  load: ->
    $log.debug 'loading kongregate script...'
    $.getScript 'https://cdn1.kongregate.com/javascripts/kongregate_api.js'
      .done (script, textStatus, xhr) =>
        $log.debug 'kongregate script loaded, now trying to load api', window.kongregateAPI
        # loadAPI() requires an actual kongregate frame, `?kongregate=1` in its own tab is insufficient. fails silently.
        window.kongregateAPI.loadAPI =>
          $log.debug 'kongregate api loaded'
          @kongregate = window.kongregateAPI.getAPI()
          @_onLoad()
      .fail (xhr, settings, exception) =>
        $log.error 'kongregate load failed', xhr, settings, exception

  _onLoad: ->
    $log.debug 'kongregate successfully loaded!', @kongregate
    @isLoaded = true
    @reportStats()

  reportStats: ->
    if not @isLoaded or not game.session.kongregate
      return
    # don't report more than once per minute
    now = new Date()
    if @lastReported and now.getTime() < @lastReported.getTime() + 60 * 1000
      return
    if not @lastReported
      @kongregate.stats.submit 'Initialized', 1
    @lastReported = now
    @kongregate.stats.submit 'Hatcheries', @_count game.upgrade 'hatchery'
    @kongregate.stats.submit 'Expansions', @_count game.upgrade 'expansion'
    @kongregate.stats.submit 'GameComplete', @_count game.unit 'ascension'
    @kongregate.stats.submit 'Mutations Unlocked', @_count game.upgrade 'mutatehidden'
    @kongregate.stats.submit 'Achievement Points', game.achievementPoints()

  _count: (u) ->
    return u.count().floor().toNumber()

angular.module('swarmApp').factory 'kongregate', ($log, Kongregate) ->
  ret = new Kongregate()
  $log.debug 'isKongregate:', ret.isKongregate()
  if ret.isKongregate()
    ret.load()
  return ret
