/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Directive: tutorial', function() {

  // load the directive's module
  beforeEach(module('swarmApp'));

  let scope = {};

  beforeEach(inject(($controller, $rootScope) => scope = $rootScope.$new())
  );

  return xit('should make hidden element visible', inject(function($compile) {
    let element = angular.element('<tutorial></tutorial>');
    element = $compile(element)(scope);
    return expect(element.text()).toBe('this is the tutorial directive');
  })
  );
});
