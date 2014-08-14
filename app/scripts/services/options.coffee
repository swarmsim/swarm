'use strict'

###*
 # @ngdoc service
 # @name swarmApp.options
 # @description
 # # options
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Options', -> class Options
  constructor: (@session) ->

  maybeSet: (field, val) ->
    if val?
      console.log 'set fps', field, val
      @set field, val
  set: (field, val) ->
    @session.options[field] = val
    @session.save()
  get: (field, default_) ->
    return @session.options[field] ? default_
  reset: (field) ->
    delete @session.options[field]

  fps: (val) ->
    @maybeSet 'fps', val
    Math.min 60, Math.max 1, @get 'fps', 10

  fpsSleepMillis: ->
    return 1000 / @fps()

angular.module('swarmApp').factory 'options', (Options, session) ->
  return new Options session
