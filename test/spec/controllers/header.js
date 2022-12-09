/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

xdescribe('Controller: HeaderCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let HeaderCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return HeaderCtrl = $controller('HeaderCtrl', {
      $scope: scope
    });}));

  return it('should attach env to the scope', () => expect(!!scope.env).toBe(true));
});
