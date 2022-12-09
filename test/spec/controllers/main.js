/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: MainCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let MainCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return MainCtrl = $controller('MainCtrl', {
      $scope: scope
    });}));

  return it('should attach a game to the scope', () => expect(!!scope.game).toBe(true));
});
