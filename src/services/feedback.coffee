'use strict'

###*
 # @ngdoc service
 # @name swarmApp.feedback
 # @description
 # # feedback
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'feedback', ($log, game, version, env, isKongregate) -> new class Feedback
  # other alternatives: pastebin (rate-limited), github gist
  # tinyurl doesn't allow cross-site requests
  createTinyurl: (exported=game.session.exportSave()) ->
    game.cache.tinyUrl[exported] ?= do =>
      if isKongregate()
        load_url = "https://www.swarmsim.com?kongregate=1/#/importsplash?savedata=#{encodeURIComponent exported}"
      else
        load_url = "https://swarmsim.github.io/#/importsplash?savedata=#{encodeURIComponent exported}"
      jQuery.ajax('https://www.googleapis.com/urlshortener/v1/url',
        type: 'POST'
        data:JSON.stringify
          key: env.googleApiKey
          longUrl: load_url
        contentType:'application/json'
        dataType:'json')
        .done (data, status, xhr) =>
          $log.debug 'createTinyurl success', data, status, xhr
        .fail (data, status, xhr) =>
          $log.debug 'createTinyurl fail ', data, status, xhr
