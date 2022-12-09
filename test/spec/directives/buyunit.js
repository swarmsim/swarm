/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Directive: buyunit', function() {

  // load the directive's module
  beforeEach(module('swarmApp'));

  let scope = {};
  let game = {};

  beforeEach(inject(function($controller, $rootScope, _game_) {
    scope = $rootScope.$new();
    return game = _game_;
  })
  );

  // TODO ugh this isn't working at all
  return xit('should make hidden element visible', inject(function($compile) {
    let element = angular.element('<buyunit unit="cur"></buyunit>');
    scope.cur = game.unit('drone');
    element = $compile(element)(scope);
    return expect(element.html()).not.toBe('');
  })
  );
});
