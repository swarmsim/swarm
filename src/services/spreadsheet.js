/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

// Generated from the gruntfile.
angular.module('swarmApp').factory('spreadsheet', function($log, $injector, env) {
  const data = $injector.get(`spreadsheetPreload-${env.spreadsheetKey}`);
  $log.debug('loaded spreadsheet', env.spreadsheetKey, data);
  return {data};
});
