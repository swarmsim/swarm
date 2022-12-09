/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

xdescribe('Controller: NewsArchiveCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let NewsArchiveCtrl = {};

  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return NewsArchiveCtrl = $controller('NewsArchiveCtrl', {
      // place here mocked dependencies
    });}));

  return it('should attach a list of awesomeThings to the scope', () => expect(NewsArchiveCtrl.awesomeThings.length).toBe(3));
});
