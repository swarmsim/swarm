/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: ErrorsavingCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let ErrorSavingCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return ErrorSavingCtrl = $controller('ErrorSavingCtrl', {
      $scope: scope
    });}));

  return it('exists', () => expect(!!scope).toBe(true));
});
