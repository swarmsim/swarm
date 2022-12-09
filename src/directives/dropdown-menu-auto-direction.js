/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import $ from 'jquery';

angular.module('swarmApp').directive('dropdownMenuAutoDirection', ($compile, $log) => ({
  restrict: 'A',

  link(scope, element, attrs) {
    const dropdownMenuClassName = function() {
      // https://stackoverflow.com/questions/17095851/check-if-element-is-off-right-edge-of-screen
      const rightEdge = $(element).width() + $(element).offset().left;
      const screenWidth = $(window).width();
      const rightLeft = screenWidth < rightEdge ? 'right' : 'left';
      return 'dropdown-menu-'+rightLeft;
    };
    return attrs.$set('class', 'dropdown-menu '+dropdownMenuClassName());
  }
}));
