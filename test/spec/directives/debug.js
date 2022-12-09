/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Directive: debug', function() {

  // load the directive's module
  beforeEach(module('swarmApp'));

  let scope = {};

  beforeEach(inject(($controller, $rootScope) => scope = $rootScope.$new())
  );

  return it('should make hidden element visible', inject(function($compile) {
    let element = angular.element('<debug></debug>');
    return element = $compile(element)(scope);
  })
  );
});
    //expect(element.text()).toBe 'this is the debug directive'
