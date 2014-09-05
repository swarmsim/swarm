'use strict'

angular.module('swarmApp').value 'analyticsDimensionList',
  ['version']

angular.module('swarmApp').factory 'analyticsDimensions', (analyticsDimensionList) ->
  ret = {}
  i = 0
  for name in analyticsDimensionList
    ret[name] = "dimension#{++i}"
  return ret
    
angular.module('swarmApp').value 'analyticsMetricList',
  ['saveFileChars', 'clickLogChars']

angular.module('swarmApp').factory 'analyticsMetrics', (analyticsMetricList) ->
  ret = {}
  i = 0
  for name in analyticsMetricList
    ret[name] = "metric#{++i}"
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
  if env == 'test' or not window.ga?
    return
  #console.log 'ga.set', dims.version, version
  window.ga 'set', dims.version, version

  $rootScope.$on 'select', (event, args) ->
    name = args?.unit?.name ? '#back-button'
    $analytics.pageTrack "/unit/#{name}"

  $rootScope.$on 'save', (event, args) ->
    #console.log 'save event'
    #$analytics.eventTrack 'save', {}
    #console.log 'ga.set', metrics.saveFileChars, session.exportSave().length
    window.ga 'set', metrics.saveFileChars, session.exportSave().length
    #console.log 'ga.set', metrics.clickLogChars, statistics.replay.compressToUTF16().length
    window.ga 'set', metrics.clickLogChars, statistics.replay.compressToUTF16().length

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
  logThrottledError = (action, label) ->
    errorCount += 1
    if errorCount <= ERROR_THROTTLE_THRESHOLD
      label = if _.isString label then label else JSON.stringify label
      $log.debug 'logging error to google analytics', {category:'error', action:action, label: label}
      $analytics.eventTrack action,
        category: 'error'
        label: label
      if errorCount == ERROR_THROTTLE_THRESHOLD
        $log.warn 'error threshold reached, no more errors will be reported to analytics'
        $analytics.eventTrack 'maxErrorCount',
          category: 'error'
          label: 'too many errors logged to analytics this session, future errors will not be logged'

  $rootScope.$on 'unhandledException', (event, args) ->
    try
      if args.exception?.name? and args.exception?.message?
        label = "#{args.exception.name}: #{args.exception.message}"
      else
        label = if _.isString args.exception then args.exception else JSON.stringify args.exception
        label = "Unknown exception: #{label}"
      logThrottledError 'unhandledException', label
    catch e
      # no infinite loops plz
      logThrottledError 'unhandledExceptionLoop', "#{e?.name}: #{e?.message}"

  $rootScope.$on 'error', (event, args) ->
    logThrottledError 'emittedError', args

  $rootScope.$on 'assertionFailure', (event, args) ->
    logThrottledError 'assertionFailure', args
