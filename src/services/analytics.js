/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

angular.module('swarmApp').value('analyticsDimensionList',
  ['version']);

angular.module('swarmApp').factory('analyticsDimensions', function(analyticsDimensionList) {
  const ret = {};
  let i = 0;
  for (var name of Array.from(analyticsDimensionList)) {
    i += 1;
    ret[name] = `dimension${i}`;
  }
  return ret;
});
    
angular.module('swarmApp').value('analyticsMetricList',
  ['saveFileChars', 'clickLogChars']);

angular.module('swarmApp').factory('analyticsMetrics', function(analyticsMetricList) {
  const ret = {};
  let i = 0;
  for (var name of Array.from(analyticsMetricList)) {
    i += 1;
    ret[name] = `metric${i}`;
  }
  return ret;
});
    
/**
 * @ngdoc service
 * @name swarmApp.analytics
 * @description
 * # analytics
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('analytics', function($rootScope, $analytics, env, game, version, analyticsDimensions, analyticsMetrics, statistics, session, $log) {
  const dims = analyticsDimensions;
  const metrics = analyticsMetrics;
  // no analytics during testing. also, window.ga might be blank if someone blocks google analytics.
  if (!env.gaTrackingID || (window.ga == null)) {
    $log.debug('skipping analytics event logging', window.ga, env.gaTrackingID);
    return;
  }
  //console.log 'ga.set', dims.version, version
  window.ga('set', dims.version, version);

  $rootScope.$on('select', function(event, args) {
    const name = __guard__(args != null ? args.unit : undefined, x => x.name) != null ? __guard__(args != null ? args.unit : undefined, x => x.name) : '#back-button';
    return $analytics.pageTrack(`/oldui/unit/${name}`);
  });

  $rootScope.$on('save', (event, args) => //console.log 'save event'
  //$analytics.eventTrack 'save', {}
  //console.log 'ga.set', metrics.saveFileChars, session.exportSave().length
  window.ga('set', metrics.saveFileChars, session.exportSave().length));

  $rootScope.$on('achieve', (event, achievement) => $analytics.eventTrack('achievementEarned', {
    category:'achievement',
    label:achievement.name,
    value:achievement.earnedAtMillisElapsed()
  }
  ));

  $rootScope.$on('command', (event, cmd) => //console.log 'command event', event.name, cmd.name, cmd
  $analytics.eventTrack(cmd.name, {
    category:'command',
    label:cmd.unitname != null ? cmd.unitname : cmd.upgradename,
    value:cmd.twinnum != null ? cmd.twinnum : cmd.num
  }));

  $rootScope.$on('buyFirst', (event, cmd) => $analytics.eventTrack(`buyFirst:${cmd.name}`, {
    category:'buyFirst',
    label:cmd.unitname != null ? cmd.unitname : cmd.upgradename,
    value:cmd.elapsed
  }
  ));

  $rootScope.$on('reset', event => $analytics.eventTrack('reset',
    {category:'reset'}));

  $rootScope.$on('import', (event, args) => $analytics.eventTrack('import', {
    category:'import',
    value:args.success ? 1 : 0
  }
  ));

  $rootScope.$on('timecheckFailed', (event, args) => $analytics.eventTrack('timecheckFailed',
    {category:'timecheck'}));
  $rootScope.$on('timecheckError', (event, args) => $analytics.eventTrack('timecheckError',
    {category:'timecheck'}));

  let errorCount = 0;
  const ERROR_THROTTLE_THRESHOLD = 12;
  const logThrottledError = exception => logThrottledEvent((exception != null ? exception.message : undefined) != null ? (exception != null ? exception.message : undefined) : exception, exception, 'captureException');
  const logThrottledMessage = message => logThrottledEvent(message, message, 'captureMessage');
  var logThrottledEvent = (message, logged, key) => errorCount += 1;

  $rootScope.$on('unhandledException', function(event, args) {
    try {
      return logThrottledError(args.exception);
    } catch (e) {
      // no infinite loops plz
      try {
        return $log.warn('unhandled exception error logging loop', e);
      } catch (e2) {
        return $log.warn('exception logging failed, giving up', e2);
      }
    }
  });

  $rootScope.$on('error', (event, args) => logThrottledMessage('emittedError', args));

  $rootScope.$on('assertionFailure', (event, args) => logThrottledMessage('assertionFailure', args));

  return $rootScope.$on('loadGameFromStorageFailed', (event, message) => logThrottledMessage('loadGameFromStorageFailed', message));
});

  //$rootScope.$on 'savedGameRecoveredFromFlash', (event, args) ->
  //  $analytics.eventTrack 'savedGameRecoveredFromFlash',
  //    category:'import'

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}