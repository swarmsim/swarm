'use strict'

angular.module('swarmApp').value 'analyticsDimensionList',
  ['version']

angular.module('swarmApp').factory 'analyticsDimensions', (analyticsDimensionList) ->
  ret = {}
  i = 0
  for name in analyticsDimensionList
    i += 1
    ret[name] = "dimension#{i}"
  return ret
    
angular.module('swarmApp').value 'analyticsMetricList',
  ['saveFileChars', 'clickLogChars']

angular.module('swarmApp').factory 'analyticsMetrics', (analyticsMetricList) ->
  ret = {}
  i = 0
  for name in analyticsMetricList
    i += 1
    ret[name] = "metric#{i}"
  return ret
    
###*
 # @ngdoc service
 # @name swarmApp.analytics
 # @description
 # # analytics
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'analytics', ($rootScope, $analytics, env, game, version, analyticsDimensions, analyticsMetrics, statistics, session, $log) ->
  dims = analyticsDimensions
  metrics = analyticsMetrics
  # no analytics during testing. also, window.ga might be blank if someone blocks google analytics.
  if not env.gaTrackingID or not window.ga?
    $log.debug 'skipping analytics event logging', window.ga, env.gaTrackingID
    return
  #console.log 'ga.set', dims.version, version
  window.ga 'set', dims.version, version

  $rootScope.$on 'select', (event, args) ->
    name = args?.unit?.name ? '#back-button'
    $analytics.pageTrack "/oldui/unit/#{name}"

  $rootScope.$on 'save', (event, args) ->
    #console.log 'save event'
    #$analytics.eventTrack 'save', {}
    #console.log 'ga.set', metrics.saveFileChars, session.exportSave().length
    window.ga 'set', metrics.saveFileChars, session.exportSave().length

  $rootScope.$on 'achieve', (event, achievement) ->
    $analytics.eventTrack 'achievementEarned',
      category:'achievement'
      label:achievement.name
      value:achievement.earnedAtMillisElapsed()

  $rootScope.$on 'command', (event, cmd) ->
    #console.log 'command event', event.name, cmd.name, cmd
    $analytics.eventTrack cmd.name,
      category:'command'
      label:cmd.unitname ? cmd.upgradename
      value:cmd.twinnum ? cmd.num

  $rootScope.$on 'buyFirst', (event, cmd) ->
    $analytics.eventTrack "buyFirst:#{cmd.name}",
      category:'buyFirst'
      label:cmd.unitname ? cmd.upgradename
      value:cmd.elapsed

  $rootScope.$on 'reset', (event) ->
    $analytics.eventTrack 'reset',
      category:'reset'

  $rootScope.$on 'import', (event, args) ->
    $analytics.eventTrack 'import',
      category:'import'
      value:if args.success then 1 else 0

  $rootScope.$on 'timecheckFailed', (event, args) ->
    $analytics.eventTrack 'timecheckFailed',
      category:'timecheck'
  $rootScope.$on 'timecheckError', (event, args) ->
    $analytics.eventTrack 'timecheckError',
      category:'timecheck'

  errorCount = 0
  ERROR_THROTTLE_THRESHOLD = 12
  IGNORED_ERRORS = [/We require more resources/, /too many errors logged to analytics this session/]
  logThrottledError = (exception) ->
    logThrottledEvent exception?.message ? exception, exception, 'captureException'
  logThrottledMessage = (message) ->
    logThrottledEvent message, message, 'captureMessage'
  logThrottledEvent = (message, logged, key) ->
    for re in IGNORED_ERRORS
      if re.test message
        return

    errorCount += 1
    if errorCount <= ERROR_THROTTLE_THRESHOLD
      if Math.random() < 0.01 # random error samples; stop hammering sentry
        Raven[key] logged
      #$log.debug 'logging error to sentry', logged
      if errorCount == ERROR_THROTTLE_THRESHOLD
        $log.warn 'error threshold reached, no more errors will be reported to sentry'
        Raven.captureMessage 'error threshold reached, no more errors will be reported to sentry'

  $rootScope.$on 'unhandledException', (event, args) ->
    try
      logThrottledError args.exception
    catch e
      # no infinite loops plz
      try
        $log.warn 'unhandled exception error logging loop', e
        Raven.captureError e
      catch e2
        $log.warn 'exception logging failed, giving up', e2

  $rootScope.$on 'error', (event, args) ->
    logThrottledMessage 'emittedError', args

  $rootScope.$on 'assertionFailure', (event, args) ->
    logThrottledMessage 'assertionFailure', args

  $rootScope.$on 'loadGameFromStorageFailed', (event, message) ->
    logThrottledMessage 'loadGameFromStorageFailed', message

  #$rootScope.$on 'savedGameRecoveredFromFlash', (event, args) ->
  #  $analytics.eventTrack 'savedGameRecoveredFromFlash',
  #    category:'import'
