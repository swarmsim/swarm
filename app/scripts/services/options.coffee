'use strict'

###*
 # @ngdoc service
 # @name swarmApp.options
 # @description
 # # options
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Options', ($log, util) -> class Options
  constructor: (@session) ->
    @VELOCITY_UNITS = byName:{}, list:[]
    addvunit = (name, label, plural, mult) =>
      vu = name:name, label:label, plural:plural, mult:mult
      @VELOCITY_UNITS.byName[vu.name] = vu
      @VELOCITY_UNITS.list.push vu
    addvunit 'sec', 'second', 'seconds', 1
    addvunit 'min', 'minute', 'minutes', 60
    addvunit 'hr', 'hour', 'hours', 60 * 60
    addvunit 'day', 'day', 'days', 60 * 60 * 24

  maybeSet: (field, val, valid) ->
    if val?
      $log.debug 'set options value', field, val
      if valid?
        util.assert valid[val], "invalid option for #{field}: #{val}"
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

  showAdvancedUnitData: (val) ->
    @maybeSet 'showAdvancedUnitData', val
    !!@get 'showAdvancedUnitData'

  durationFormat: (val) ->
    if val?
      valid = {'human':true, 'full':true, 'abbreviated':true }
      util.assert valid[val], 'invalid options.durationFormat value', val
      @maybeSet 'durationFormat', val
    @get 'durationFormat', 'human'

  notation: (val) ->
    if val?
      valid = {'standard-decimal':true, 'scientific-e':true, 'hybrid':true, 'engineering':true}
      util.assert valid[val], 'invalid options.notation value', val
      @maybeSet 'notation', val
    @get 'notation', 'standard-decimal'

  velocityUnit: (name) ->
    @maybeSet 'velocityUnit', name, @VELOCITY_UNITS.byName
    return @VELOCITY_UNITS.byName[@get 'velocityUnit'] ? @VELOCITY_UNITS.list[0]

  # Scrolling style on kongregate/iframed pages
  scrolling: (name) ->
    @maybeSet 'scrolling', name, {'none':true, 'resize':true}
    return @get('scrolling') ? 'none'

  theme: (name) ->
    @maybeSet 'theme', name, {'none':true, 'dark-ff':true, 'dark-chrome':true}
    return @get('theme') ? 'none'

angular.module('swarmApp').factory 'options', (Options, session) ->
  return new Options session
