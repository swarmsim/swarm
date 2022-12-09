/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Controller: AchievementsCtrl', function() {

  // load the controller's module
  beforeEach(module('swarmApp'));

  let AchievementsCtrl = {};
  let scope = {};

  // Initialize the controller and a mock scope
  beforeEach(inject(function($controller, $rootScope) {
    scope = $rootScope.$new();
    return AchievementsCtrl = $controller('AchievementsCtrl', {
      $scope: scope
    });}));

  return it('exists', () => expect(!!scope.game).toBe(true));
});
