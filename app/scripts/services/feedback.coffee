'use strict'

###*
 # @ngdoc service
 # @name swarmApp.feedback
 # @description
 # # feedback
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'feedback', ($log, game, version) -> new class Feedback
  # other alternatives: pastebin (rate-limited), github gist
  # tinyurl doesn't allow cross-site requests
  createTinyurl: (exported=game.session.exportSave()) ->
    load_url = "http://swarmsim.github.io/#/savedata=#{encodeURIComponent exported}"
    jQuery.ajax('https://www.googleapis.com/urlshortener/v1/url',
      type: 'POST'
      data:JSON.stringify
        longUrl:load_url
      contentType:'application/json'
      dataType:'json')
      .done (data, status, xhr) =>
        $log.debug 'createTinyurl success', data, status, xhr
      .fail (data, status, xhr) =>
        $log.debug 'createTinyurl fail ', data, status, xhr
