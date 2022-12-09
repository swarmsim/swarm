/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.decorator:Exceptionhandler
 * @description
 * # Exceptionhandler
 * Decorator of the swarmApp
*/
angular.module("swarmApp").config($provide => // in most places minification can figure out what's going on without
// argnames-as-list, but not here. Fails in dist-build without them.
$provide.decorator(
  "$exceptionHandler",
  ['$delegate', '$injector', function($delegate, $injector) {
    let $rootScope = null;
    return function(exception, cause) {
      $delegate(exception, cause);
      if ($rootScope == null) { $rootScope = $injector.get('$rootScope'); } //avoid circular dependency error
      return $rootScope.$emit('unhandledException', {exception, cause});
    };
  }
  ]
));
