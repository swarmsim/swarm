'use strict'

angular.module('swarmApp').value 'lazySpreadsheetUrl', 'https://docs.google.com/spreadsheets/d/1FgPdB1RzwCvK_gvfFuf0SU9dWJbAmYtewF8A-4SEIZM/pubhtml'

###*
 # @ngdoc service
 # @name swarmApp.spreadsheet
 # @description
 # # spreadsheet
 # Service in the swarmApp.
 # UNUSED - we use preloaded spreadsheet data now.
###
angular.module('swarmApp').factory 'lazySpreadsheet', ($q, lazySpreadsheetUrl) ->
  promise = $q.defer()
  Tabletop.init
    key: spreadsheetUrl
    parseNumbers: true
    debug: true
    callback: (data, tabletop) ->
      promise.resolve data:data, tabletop:tabletop
  return promise.promise

# Generated from the gruntfile.
angular.module('swarmApp').factory 'spreadsheet', (spreadsheetPreload) ->
  data:spreadsheetPreload
