'use strict'

###*
 # @ngdoc service
 # @name swarmApp.options
 # @description
 # # options
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Options', ($log, util, env) -> class Options
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

  showAccurateTiming: (val) ->
    @maybeSet 'showAccurateTiming', val
    !!@get 'showAccurateTiming'

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
    @maybeSet 'scrolling', name, {'none':true, 'resize':true, 'lockhover'}
    return @get('scrolling') ? 'none'

  # can't attach an id to the theme element - usemin-compiled
  @THEME_EL: $('link[href^="styles/bootstrapdefault"]')
  @THEMES: do ->
    # don't assert this in dev because it breaks tests
    util.assert (env.isDebugEnabled || Options.THEME_EL[0]), "couldn't find theme link"
    ret =
      list: []
    ret.list.push
      name: 'none'
      label: 'Default white'
      #url: '//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css'
      url: Options.THEME_EL.attr('href')
      credit: 'http://bootswatch.com/default/'
    # bootswatch themes
    for name in ['cerulean', 'cosmo', 'cyborg', 'darkly', 'flatly', 'journal', 'lumen', 'paper', 'readable', 'sandstone', 'simplex', 'slate', 'spacelab', 'superhero', 'united', 'yeti']
      ret.list.push
        name: name
        label: name
        #url: "//maxcdn.bootstrapcdn.com/bootswatch/3.3.2/#{name}/bootstrap.min.css" # why do people block the cdn srsly
        url: "bower_components/bootswatch/#{name}/bootstrap.min.css"
        credit: "http://bootswatch.com/#{name}/"
    ret.byName = _.indexBy ret.list, 'name'
    return ret

  theme: (name) ->
    # getter for both theme and customTheme
    if name?
      @set 'isCustomTheme', false
      @maybeSet 'theme', name, Options.THEMES.byName

    if @get 'isCustomTheme'
      return @get('theme')
    else
      name = @get('theme') ? 'none'
      # legacy themes. pick another dark theme.
      if name == 'dark-ff' or name == 'dark-chrome'
        name = 'slate'
      return Options.THEMES.byName[name]

  customTheme: (url) ->
    @set 'isCustomTheme', true
    @set 'theme', {isCustom:true,url:url}

angular.module('swarmApp').factory 'options', (Options, session) ->
  return new Options session
