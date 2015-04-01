'use strict'

###*
 # @ngdoc service
 # @name swarmApp.options
 # @description
 # # options
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'Options', ($log, util, env, game, $location) -> class Options
  constructor: (@session) ->
    @VELOCITY_UNITS = byName:{}, list:[]
    addvunit = (name, label, plural, mult) =>
      vu = name:name, label:label, plural:plural, mult:mult
      if _.isFunction mult
        vu._get = ->
          ret = _.clone this
          ret.mult = ret.mult()
          return ret
      else
        vu._get = -> return this
      @VELOCITY_UNITS.byName[vu.name] = vu
      @VELOCITY_UNITS.list.push vu
    addvunit 'sec', 'second', 'seconds', 1
    addvunit 'min', 'minute', 'minutes', 60
    addvunit 'hr', 'hour', 'hours', 60 * 60
    addvunit 'day', 'day', 'days', 60 * 60 * 24
    addvunit 'warp', 'Swarmwarp', 'Swarmwarp', -> game.upgrade('swarmwarp').effect[0].output()

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
      valid = {'human':true, 'full':true, 'abbreviated':true}
      util.assert valid[val], 'invalid options.durationFormat value', val
      @maybeSet 'durationFormat', val
    @get 'durationFormat', 'abbreviated'

  notation: (val) ->
    if val?
      valid = {'standard-decimal':true, 'scientific-e':true, 'hybrid':true, 'engineering':true}
      util.assert valid[val], 'invalid options.notation value', val
      @maybeSet 'notation', val
    @get 'notation', 'standard-decimal'

  velocityUnit: (name, opts={}) ->
    @maybeSet 'velocityUnit', name, @VELOCITY_UNITS.byName
    ret = @VELOCITY_UNITS.byName[@get 'velocityUnit']
    # special case: swarmwarp produces no energy, so default to seconds
    if (not ret?) or (ret.name == 'warp' and (
      ((opts.unit?.name ? opts.unit) == 'energy') or
      ((opts.prod?.name ? opts.prod) == 'nexus')))
      ret = @VELOCITY_UNITS.list[0]
    return ret._get()
  getVelocityUnit: (opts={}) ->
    return @velocityUnit undefined, opts

  # Scrolling style on kongregate/iframed pages
  scrolling: (name) ->
    @maybeSet 'scrolling', name, {'none':true, 'resize':true, 'lockhover'}
    return @get('scrolling') ? 'none'

  autopush: (enabled) ->
    @maybeSet 'autopush', enabled
    return @get('autopush') ? true

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

  showCharts: (enabled) ->
    @maybeSet 'showCharts', enabled
    return @get('showCharts') ? true

  @THEME_EXTRA_LENGTH = 1000
  themeExtra: (css) ->
    if css?
      if css.length >= @constructor.THEME_EXTRA_LENGTH
        throw new Error "But it's so big!"
      @set 'themeExtra', css
    if @isAprilFoolsTheme() and @aprilFoolsState() == 'on'
      return "@import url('/static/kittens.css?1');"
    return @get 'themeExtra', null

  # options is a strange place for this, but themeExtra needs it
  aprilFoolsState: ->
    # ?forcefools=[on|after|off] to force this state for testing, no clock-changes required
    if (ret=$location.search().forcefools)?
      return ret

    now = moment()
    # test times.
    # off (before)
    #now = moment.parseZone '2015-03-31T23:00:00-05:00' # because moment.parseZone('2015-03-31T23:00:00-05:00').isBefore('2015-03-31T21:00:00-08:00')
    # on
    #now = moment.parseZone '2015-03-31T21:05:00-08:00'
    #now = moment.parseZone '2015-04-01T00:01:00-05:00'
    # after
    #now = moment.parseZone '2015-04-01T21:00:00-08:00'
    #now = moment.parseZone '2015-04-03T21:00:00-08:00'
    # off (after)
    #now = moment.parseZone '2015-04-04T21:00:00-08:00'

    # use the same timezone for everyone, so it appears at around the same time for everyone and earlier timezones don't spoil it.
    # this means it starts at the wrong time for non-americans, whom we have lots of. oh well, a consistent start is more important; sorry folks.
    # start a few hours early, between 3/31 21:00 PST (00:00 EST) and 4/1 00:00 PST
    # -07:00 (not -08:00) because daylight savings
    if now.isBetween moment.parseZone('2015-03-31T21:00:00-07:00'), moment.parseZone('2015-04-02T00:00:00-07:00')
      return 'on'
    if now.isBetween moment.parseZone('2015-04-02T00:00:00-07:00'), moment.parseZone('2015-04-04T00:00:00-07:00')
      return 'after'
    return 'off'
  isAprilFoolsTheme: (enabled) ->
    @maybeSet 'aprilFoolsTheme', enabled
    return @get('aprilFoolsTheme') ? false


angular.module('swarmApp').factory 'options', (Options, session) ->
  return new Options session
