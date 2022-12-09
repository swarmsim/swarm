/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: FeedbackCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let FeedbackCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return FeedbackCtrl = $controller('FeedbackCtrl', {
      $scope: scope
    });}));

  return xit('exists', () => expect(!!scope).toBe(true));
});
