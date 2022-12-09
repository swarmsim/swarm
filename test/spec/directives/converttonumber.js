/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Directive: converttonumber', function() {

  // load the directive's module
  beforeEach(module('swarmApp'));

  let scope = {};

  beforeEach(inject(($controller, $rootScope) => scope = $rootScope.$new())
  );

  return xit('should make hidden element visible', inject(function($compile) {
    let element = angular.element('<converttonumber></converttonumber>');
    element = $compile(element)(scope);
    return expect(element.text()).toBe('this is the converttonumber directive');
  })
  );
});
