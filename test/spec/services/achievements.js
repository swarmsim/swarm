/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: achievements', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let achievements = {};
  let Achievement = {};
  const game = {session:{state:{achievements:{}}}, withUnreifiedSave(fn) { return fn(); }};
  beforeEach(inject(function(_achievements_, _Achievement_) {
    achievements = _achievements_;
    return Achievement = _Achievement_;
  })
  );

  it('should do something', function() {
    expect(!!achievements).toBe(true);
    return expect(achievements.list.length).toBeGreaterThan(0);
  });
  
  it('earns', function() {
    const achieve = new Achievement(game, achievements.byName.drone1);
    expect(achieve.isEarned()).toBe(false);
    expect(achieve.earnedAtMillisElapsed()).toBeUndefined();
    expect(achieve.pointsEarned()).toBe(0);
    achieve.earn(55);
    expect(achieve.isEarned()).toBe(true);
    expect(achieve.earnedAtMillisElapsed()).toBe(55);
    return expect(achieve.pointsEarned()).toBe(10);
  });

  return it('describes', () => (() => {
    const result = [];
    for (var achievement of Array.from(achievements.list)) {
      var a = new Achievement(game, achievement);
      expect(() => a.description()).not.toThrow();
      result.push(expect(_.includes(a.description(), '$REQUIRE')).toBe(false));
    }
    return result;
  })());
});
