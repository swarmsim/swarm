/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:FlashqueueCtrl
 * @description
 * # FlashqueueCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('FlashQueueCtrl', ($scope, flashqueue) => $scope.achieveQueue = flashqueue);
