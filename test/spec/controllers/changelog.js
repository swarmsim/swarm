/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: ChangelogCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let ChangelogCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return ChangelogCtrl = $controller('ChangelogCtrl', {
      $scope: scope
    });}));

  return it('should exist, but not really do much. All the work is in the view', () => expect(!!scope).toBe(true));
});
