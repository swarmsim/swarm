'use strict'

angular.module('swarmApp').value 'spreadsheetUrl', 'https://docs.google.com/spreadsheets/d/1FgPdB1RzwCvK_gvfFuf0SU9dWJbAmYtewF8A-4SEIZM/pubhtml'

###*
 # @ngdoc service
 # @name swarmApp.spreadsheet
 # @description
 # # spreadsheet
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'spreadsheet', ($q, spreadsheetUrl, spreadsheetPreload) ->
  promise = $q.defer()
  #console.log 'spreadsheetPreload', spreadsheetPreload
  promise.resolve data:spreadsheetPreload
  #Tabletop.init
  #  key: spreadsheetUrl
  #  parseNumbers: true
  #  debug: true
  #  callback: (data, tabletop) ->
  #    promise.resolve data:data, tabletop:tabletop
  return promise.promise
