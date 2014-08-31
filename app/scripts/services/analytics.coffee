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
angular.module('swarmApp').factory 'analytics', ($rootScope, $analytics, env, game, version, analyticsDimensions, analyticsMetrics, statistics, session) ->
  dims = analyticsDimensions
  metrics = analyticsMetrics
  # no analytics during testing
  if env == 'test'
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
