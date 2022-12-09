/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: ImportsplashCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let ImportsplashCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return ImportsplashCtrl = $controller('ImportsplashCtrl', {
      $scope: scope
    });}));

  return xit('should attach a list of awesomeThings to the scope', () => expect(scope.awesomeThings.length).toBe(3));
});
