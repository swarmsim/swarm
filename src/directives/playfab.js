/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
// TODO
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:playfab
 * @description
 * # playfab
*/
angular.module('swarmApp').directive('wwwPlayfab', (playfab, wwwPlayfabSyncer) => // <div ng-include="'views/playfab/title.html'"></div>
({
  template: `\
<div ng-if="isVisible()">
  <playfabauth ng-if="!isAuthed()"></playfabauth>
  <playfaboptions ng-if="isAuthed()"></playfaboptions>
</div>\
`,

  restrict: 'EA',
  scope: {},

  link(scope, element, attrs) {
    scope.isVisible = () => wwwPlayfabSyncer.isVisible();
    return scope.isAuthed = () => playfab.isAuthed();
  }
}));

// this is pretty ugly. Mostly copied/modified from the old KongregateS3Ctrl
angular.module('swarmApp').directive('kongregatePlayfab', (
  $log,
  env,
  kongregate,
  kongregateS3Syncer,
  kongregatePlayfabSyncer,
  options,
  $timeout
) => // <div ng-include="'views/playfab/kongregate.html'"></div>
({
  template: `\
<div ng-if="isVisible">
</div>\
`,

  restrict: 'EA',
  scope: {},

  link(scope, element, attrs) {
    // This switches Kongregate's online-save backend from S3 to Playfab. Compare with kongregateS3Ctrl. Soon, we'll kill the S3 backend.
    const syncer = kongregatePlayfabSyncer;
    // http://www.kongregate.com/pages/general-services-api
    scope.kongregate = kongregate;
    scope.env = env;
    scope.options = options;
    if (!env.isKongregateSyncEnabled || !kongregate.isKongregate()) {
      return;
    }
    var clear = scope.$watch('kongregate.kongregate', function(newval, oldval) {
      if (newval != null) {
        clear();
        return onload();
      }
    });

    scope.isVisible = syncer.isVisible();
    scope.isGuest = () => (scope.api == null) || scope.api.isGuest();
    scope.saveServerUrl = env.saveServerUrl;
    scope.remoteSave = () => syncer.fetchedSave();
    scope.remoteDate = () => syncer.fetchedDate();
    scope.getAutopushError = () => syncer.getAutopushError();

    var onload = function() {
      scope.api = kongregate.kongregate.services;
      scope.api.addEventListener('login', event => scope.$apply());
      return scope.init();
    };

    scope.isBrowserSupported = () => (window.FormData != null) && (window.Blob != null);

    var cooldown = (scope.cooldown = {
      byName: {},
      set(name, wait) {
        if (wait == null) { wait = 5000; }
        return cooldown.byName[name] = $timeout((() => cooldown.clear(name)), wait);
      },
      clear(name) {
        if (cooldown.byName[name]) {
          $timeout.cancel(cooldown.byName[name]);
          return delete cooldown.byName[name];
        }
      }
    });

    scope.init = function(force) {
      scope.policyError = null;
      cooldown.set('init');
      return syncer.init();
    };

    scope.fetch = function() {
      cooldown.set('fetch');
      return syncer.fetch().then(
        function(result) {
          cooldown.clear('fetch');
          return $log.debug('kong syncer fetched', result, syncer);
        },
          //scope.$apply()
        function(error) {
          cooldown.clear('fetch');
          // 404 is fine. no game saved yet
          if (data.status !== 404) {
            return scope.policyError = `Failed to fetch remote saved game: ${(typeof data !== 'undefined' && data !== null ? data.status : undefined)}, ${(typeof data !== 'undefined' && data !== null ? data.statusText : undefined)}, ${(typeof data !== 'undefined' && data !== null ? data.responseText : undefined)}`;
          }
          //scope.$apply()
      });
    };

    scope.push = function() {
      cooldown.set('push');
      return syncer.push().then(
        res => cooldown.clear('push'),
          //scope.$apply()
        function(error) {
          cooldown.clear('push');
          return scope.policyError = `Error pushing remote saved game: ${error}`;
          //scope.$apply()
      });
    };

    scope.pull = () => syncer.pull();

    return scope.clear = function() {
      if (!confirm("Once online data's deleted, there's no undo. Are you sure?")) { return; }
      cooldown.set('clear');
      return syncer.clear().then(
        res => cooldown.clear('clear'),
          //scope.$apply()
        function(error) {
          cooldown.clear('clear');
          return scope.policyError = `Error clearing remote saved game: ${error}`;
          //scope.$apply()
      });
    };
  }
}));
