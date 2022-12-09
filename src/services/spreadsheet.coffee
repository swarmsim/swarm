'use strict'

# Generated from the gruntfile.
angular.module('swarmApp').factory 'spreadsheet', ($log, $injector, env) ->
  data = $injector.get "spreadsheetPreload-#{env.spreadsheetKey}"
  $log.debug 'loaded spreadsheet', env.spreadsheetKey, data
  data:data
