/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:ClearthemeCtrl
 * @description
 * # ClearthemeCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('ClearthemeCtrl', function($scope, options, $location) {
  if ($location.search().custom && $location.search().theme) {
    options.customTheme($location.search().theme);
  } else {
    let {
      theme
    } = $location.search();
    // if we're setting themeExtra without a theme, don't change the theme
    if (!$location.search().themeExtra) {
      theme = 'none';
    }
    if (theme) {
      options.theme(theme);
    }
  }
  if ($location.search().themeExtra) {
    let left;
    return options.themeExtra((left = $location.search().themeExtra) != null ? left : '');
  }
});
