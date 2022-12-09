/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:playfab
 * @description
 * # playfab
*/
angular.module('swarmApp').directive('playfaboptions', (playfab, options, session, game, wwwPlayfabSyncer) => // templateUrl: 'views/playfab/options.html'
({
  template: views.playfab.options,
  restrict: 'EA',
  scope: {},

  link(scope, element, attrs) {
    scope.form =
      {autopush: options.autopush()};
    scope.name = playfab.auth.email;
    //scope.fetched = {state: 'abcde', lastUpdated: moment(999)}
    scope.fetched = {
      state() { return (playfab.auth != null ? playfab.auth.state : undefined); },
      lastUpdated() { return moment(playfab.auth.lastUpdated); }
    };
    scope.isFetched = () => !!scope.fetched.state();

    wwwPlayfabSyncer.initAutopush(options.autopush());
    scope.setAutopush = function(val) {
      options.autopush(val);
      return wwwPlayfabSyncer.initAutopush(val);
    };

    scope.push = () => playfab.push(session.exportSave());
    scope.fetch = () => playfab.fetch();
    scope.pull = () => playfab.fetch().then(
      auth => game.importSave(auth.state),
      console.warn
    );
    scope.clear = () => confirm("Once online data's deleted, there's no undo. Are you sure?") && playfab.clear().catch(console.warn);
    scope.logout = () => playfab.logout();
    return scope.autopushError = () => wwwPlayfabSyncer.getAutopushError();
  }
}));
