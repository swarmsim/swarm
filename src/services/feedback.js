/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import jQuery from 'jquery';

/**
 * @ngdoc service
 * @name swarmApp.feedback
 * @description
 * # feedback
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('feedback', function($log, game, version, env, isKongregate) { let Feedback;
return new (Feedback = class Feedback {
  // other alternatives: pastebin (rate-limited), github gist
  // tinyurl doesn't allow cross-site requests
  createTinyurl(exported) {
    if (exported == null) { exported = game.session.exportSave(); }
    return game.cache.tinyUrl[exported] != null ? game.cache.tinyUrl[exported] : (game.cache.tinyUrl[exported] = (() => {
      let load_url;
      if (isKongregate()) {
        load_url = `https://www.swarmsim.com?kongregate=1/#/importsplash?savedata=${encodeURIComponent(exported)}`;
      } else {
        load_url = `https://swarmsim.github.io/#/importsplash?savedata=${encodeURIComponent(exported)}`;
      }
      return jQuery.ajax('https://www.googleapis.com/urlshortener/v1/url', {
        type: 'POST',
        data:JSON.stringify({
          key: env.googleApiKey,
          longUrl: load_url
        }),
        contentType:'application/json',
        dataType:'json'
      })
        .done((data, status, xhr) => {
          return $log.debug('createTinyurl success', data, status, xhr);
      }).fail((data, status, xhr) => {
          return $log.debug('createTinyurl fail ', data, status, xhr);
      });
    })());
  }
});
 });
