/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: game integration', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let game = {};
  beforeEach(inject(_game_ => game = _game_)
  );

  const clear = function(resource) {
    for (var u of Array.from(game.unitlist().concat(game.upgradelist()))) {
      u._setCount(0);
    }
    // energy cap hack
    game.unit('nexus')._setCount(5);
    return Array.from(resource.cost).map((cost) =>
      cost.unit._setCount(cost.val));
  };
    
  it("builds one of each unit", () => (() => {
    const result = [];
    for (var unit of Array.from(game.unitlist())) {
      game.cache.unitVisible[unit.name] = true;
      if (!unit.unittype.unbuyable) {
        clear(unit);
        expect(unit.count().toNumber()).toBe(0);
        unit.buy();
        result.push(expect(unit.count().toNumber()).toBe(1));
      } else {
        result.push(undefined);
      }
    }
    return result;
  })());

  // This test is really slow after adding decimal.js - had to extend browserNoActivityTimeout. Why?
  // Empower upgrades seem especially slow. Larger numbers...? It's fine in prod outside of tests though.
  return it("builds one of each upgrade", () => (() => {
    const result = [];
    for (var upgrade of Array.from(game.upgradelist())) {
      game.cache.upgradeVisible[upgrade.name] = true;
      game.cache.unitVisible[upgrade.unit.name] = true;
      clear(upgrade);
      expect(upgrade.count().toNumber()).toBe(0);
      upgrade.buy();
      result.push(expect(upgrade.count().toNumber()).toBe(1));
    }
    return result;
  })());
});
