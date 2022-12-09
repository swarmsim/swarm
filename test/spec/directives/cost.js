/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Directive: cost', function() {

  // load the directive's module
  beforeEach(module('swarmApp'));

  let scope = {};
  let game = {};
  beforeEach(inject(function($controller, $rootScope, _game_) {
    scope = $rootScope.$new();
    return game = _game_;
  })
  );

  return it('should make hidden element visible', inject(function($compile) {
    let element = angular.element('<cost costlist="[]"></cost>');
    element = $compile(element)(scope);
    return expect(element.text()).toBe('');
  })
  );
});
