/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: DebugCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let DebugCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return DebugCtrl = $controller('DebugCtrl', {
      $scope: scope
    });}));

  return it('should attach a session to the scope', () => expect(scope.session).not.toBeUndefined());
});
