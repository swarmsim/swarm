/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';

/**
 * @ngdoc function
 * @name swarmApp.controller:DecimallegendCtrl
 * @description
 * # DecimallegendCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('DecimallegendCtrl', function($scope, numberSuffixesShort, numberSuffixesLong, $log) {
  const zipped = _.zip(__range__(0, numberSuffixesShort.length, false), numberSuffixesShort, numberSuffixesLong);
  $scope.rows = (Array.from(zipped).map((z) => ({
    rownum:z[0],
    short:z[1],
    long:z[2],
    val:new Decimal(`1e${(z[0] || 0)*3}`),
    string:`1e${(z[0] || 0)*3}`
  })));
  $scope.rows[0].string += " (1)";
  $scope.rows[1].string += " (1,000)";
  $scope.rows[2].string += " (1,000,000)";
  return $log.debug($scope.rows);
});

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}