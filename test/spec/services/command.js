/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: command', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let commands = {};
  let game = {};
  beforeEach(inject(function(_commands_, _game_) {
    commands = _commands_;
    return game = _game_;
  })
  );

  it('should do something', () => expect(!!commands).toBe(true));

  it('can undo', function() {
    game.unit('meat')._setCount(10000);
    game.unit('larva')._setCount(10000);
    const drone = game.unit('drone');
    expect(drone.count().toNumber()).toBe(0);

    commands.buyUnit({unit:drone, num:1});
    expect(!!commands._undo.isRedo).not.toBe(true);
    expect(drone.count().toNumber()).toBe(1);

    commands.undo();
    expect(!!commands._undo.isRedo).toBe(true);
    expect(drone.count().toNumber()).toBe(0);

    commands.undo();
    expect(!!commands._undo.isRedo).toBe(true);
    return expect(drone.count().toNumber()).toBe(1);
  });

  return it('undoes visibility. #639', function() {
    game.unit('mutagen')._setCount(1e99);
    const upgrade = game.upgrade('mutatehatchery');
    const mutant = game.unit('mutanthatchery');
    upgrade._setCount(0);
    expect(mutant.count().toNumber()).toBe(0);
    expect(upgrade.count().toNumber()).toBe(0);
    expect(mutant.isVisible()).toBe(false);

    commands.buyUpgrade({upgrade, num:1});
    expect(mutant.count().toNumber()).toBe(1);
    expect(upgrade.count().toNumber()).toBe(1);
    expect(mutant.isVisible()).toBe(true);

    commands.undo();
    expect(mutant.count().toNumber()).toBe(0);
    expect(upgrade.count().toNumber()).toBe(0);
    return expect(mutant.isVisible()).toBe(false);
  });
});
