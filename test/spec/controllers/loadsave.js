/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: LoadsaveCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let LoadSaveCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return LoadSaveCtrl = $controller('LoadSaveCtrl', {
      $scope: scope
    });}));

  return it('should exist', () => expect(!!scope).toBe(true));
});
