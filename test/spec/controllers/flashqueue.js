/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: FlashqueueCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let FlashQueueCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return FlashQueueCtrl = $controller('FlashQueueCtrl', {
      $scope: scope
    });}));

  return it('should exist', () => expect(!!scope.achieveQueue).toBe(true));
});
