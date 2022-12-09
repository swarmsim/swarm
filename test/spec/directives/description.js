/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Directive: description', function() {

  // load the directive's module
  beforeEach(module('swarmApp'));

  let scope = {};
  beforeEach(inject(function($controller, $rootScope, game) {
    scope = $rootScope.$new();
    scope.game = game;
    return game.reset();
  })
  );

  afterEach(inject(game => game.reset())
  );

  // Now that this relies on template files, the tests break. :( TODO: fix it.
  xit('should render upgrade description with template text from spreadsheet (simple)', inject(function($compile) {
    let upgrade;
    scope.upgrade = (upgrade = scope.game.upgrade('hatchery'));
    let element = angular.element('<upgradedesc upgrade="upgrade"></upgradedesc>');
    element = $compile(element)(scope);
    const undigested = element.text();
    scope.$digest();
    expect(element.text()).toBe('Each hatchery produces 1 more larva per second. Currently, your hatcheries produce 1 larvae.');
    return expect(element.text()).not.toBe(undigested);
  })
  ); // prove the '1' really compiled, not hardcoded in spreadsheet

  return xit('should render upgrade description with template text from spreadsheet', inject(function($compile) {
    let upgrade;
    scope.upgrade = (upgrade = scope.game.upgrade('clonelarvae'));
    scope.game.now = scope.game.session.state.date.reified;
    let element = angular.element('<upgradedesc upgrade="upgrade"></upgradedesc>');
    element = $compile(element)(scope);
    //console.log element.text() # the template; {{template text}} from spreadsheet description
    // compiled element updates its {{expressions}} on digest
    scope.game.unit('larva')._setCount(665);
    scope.game.unit('cocoon')._setCount(1);
    scope.game.unit('invisiblehatchery')._setCount(1);
    scope.$digest(); // fills in {{expressions}} in element
    expect(element.text()).toBe('Clone 666 new larvae.You produce 1 larvae per second, allowing you to clone up to 100,000 larvae. You have 666 larvae and cocoons available to clone.');
    // watch it update
    scope.game.unit('cocoon')._setCount(666001);
    scope.$digest();
    return expect(element.text()).toBe('Clone 100,000 new larvae.You produce 1 larvae per second, allowing you to clone up to 100,000 larvae. You have 666,666 larvae and cocoons available to clone.');
  })
  );
});
