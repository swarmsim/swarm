/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: upgradetype', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let upgradetypes = {};
  beforeEach(inject(_upgradetypes_ => upgradetypes = _upgradetypes_)
  );

  return it('should parse the spreadsheet', function() {
    expect(!!upgradetypes).toBe(true);
    expect(!!upgradetypes.list).toBe(true);
    return expect(upgradetypes.list.length).toBeGreaterThan(4);
  });
});

describe('Service: upgrade', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let Game = {};
  let unittypes = {};
  beforeEach(inject(function(_Game_, _unittypes_) {
    Game = _Game_;
    return unittypes = _unittypes_;
  })
  );
  const mkgame = function(unittypes, reified) {
    if (reified == null) { reified = new Date(0); }
    const game = new Game({state:{unittypes, upgrades:{}, date:{reified,started:reified,restarted:reified}}, save() {}});
    game.now = new Date(0);
    return game;
  };

  // TODO why is this of all things disconnecting the test
  // ...because units have a cycle, and jasmine loops forever trying to print test failures with a cycle. D'oh.
  it('buys upgrades', function() {
    let upgrade;
    const game = mkgame({territory:999999999});
    expect(upgrade = game.upgrade('expansion')).toBe(game.unit('invisiblehatchery').upgrades.byName['expansion']);
    expect(upgrade.count().toNumber()).toBe(0);
    upgrade.buy();
    return expect(upgrade.count().toNumber()).toBe(1);
  });

  it('blocks expensive upgrades', function() {
    const game = mkgame({territory:1});
    const upgrade = game.upgrade('expansion');
    expect(upgrade.count().toNumber()).toBe(0);
    expect(() => upgrade.buy()).toThrow();
    return expect(upgrade.count().toNumber()).toBe(0);
  });

  it('calcs upgrade stats, no unit', function() {
    const game = mkgame({drone:99999999999999});
    const upgrade = game.upgrade('droneprod');
    const upgrade2 = game.upgrade('queenprod');
    let stats = {};
    const schema = {};
    upgrade.calcStats(stats, schema);
    expect(stats.prod.toNumber()).toBe(1);
    let stats2 = {};
    upgrade2.calcStats(stats2, schema);
    expect(stats2.prod.toNumber()).toBe(1);

    upgrade.buy();
    stats = {};
    upgrade.calcStats(stats, schema);
    expect(stats.prod.toNumber()).toBeGreaterThan(1);
    stats2 = {};
    upgrade2.calcStats(stats2, schema);
    return expect(stats2.prod.toNumber()).toBe(1);
  });

  it('buys/calcs max upgrades', function() {
    const game = mkgame({territory:9});
    const upgrade = game.upgrade('expansion');
    expect(upgrade.maxCostMet().toNumber()).toBe(0);
    game.unit('territory')._setCount(10);
    expect(upgrade.maxCostMet().toNumber()).toBe(1);
    game.unit('territory')._setCount(50);
    expect(upgrade.maxCostMet().toNumber()).toBe(2);
    game.unit('territory')._setCount(1000);
    expect(upgrade.maxCostMet().toNumber()).toBe(5);
    upgrade.buyMax();
    expect(upgrade.maxCostMet().toNumber()).toBe(0);
    return expect(upgrade.count().toNumber()).toBe(5);
  });

  it('clones larvae', function() {
    const game = mkgame({energy:9999999999999999999, larva:1000, invisiblehatchery:1, nexus:999});
    const upgrade = game.upgrade('clonelarvae');
    const unit = game.unit('larva');
    expect(upgrade.effect[0].bank().toNumber()).toBe(1000);
    expect(upgrade.effect[0].output().toNumber()).toBe(1000);
    upgrade.buy(3);
    expect(upgrade.count().toNumber()).toBe(3);
    expect(unit.count().toNumber()).toBe(8000);
    expect(upgrade.effect[0].bank().toNumber()).toBe(8000);
    return expect(upgrade.effect[0].output().toNumber()).toBe(8000);
  });

  it('buy more than max', function() {
    const game = mkgame({territory:10});
    const upgrade = game.upgrade('expansion');
    expect(upgrade.maxCostMet().toNumber()).toBe(1);
    expect(upgrade.count().toNumber()).toBe(0);
    upgrade.buy(10);
    expect(upgrade.maxCostMet().toNumber()).toBe(0);
    return expect(upgrade.count().toNumber()).toBe(1);
  });

  it('clones cocoons', function() {
    const game = mkgame({energy:1000000000000000000000000000000000000000, cocoon: 100, larva: 10, invisiblehatchery:1, nexus:999});
    const cocoon = game.unit('cocoon');
    const larva = game.unit('larva');
    const upgrade = game.upgrade('clonelarvae');
    expect(cocoon.count().toNumber()).toBe(100);
    expect(larva.count().toNumber()).toBe(10);
    expect(upgrade.effect[0].bank().toNumber()).toBe(110);
    expect(upgrade.effect[0].cap().toNumber()).toBe(100000);
    expect(upgrade.effect[0].output().toNumber()).toBe(110);
    upgrade.buy();
    expect(cocoon.count().toNumber()).toBe(100); // no change
    return expect(larva.count().toNumber()).toBe(120);
  }); // 0 base larvae + 100 cloned cocoons + 10 cloned larvae + 10 starting larvae

  it('caps clones', function() {
    const game = mkgame({energy:1000000000000000000000000000000000000000, cocoon: 60000, larva: 70000, invisiblehatchery:1, nexus:999});
    const cocoon = game.unit('cocoon');
    const larva = game.unit('larva');
    const upgrade = game.upgrade('clonelarvae');
    expect(cocoon.count().toNumber()).toBe(60000);
    expect(larva.count().toNumber()).toBe(70000);
    expect(upgrade.effect[0].bank().toNumber()).toBe(130000);
    expect(upgrade.effect[0].cap().toNumber()).toBe(100000);
    expect(upgrade.effect[0].output().toNumber()).toBe(100000);
    upgrade.buy();
    expect(cocoon.count().toNumber()).toBe(60000); // no change
    expect(larva.count().toNumber()).toBe(170000); // 70k base larvae + 100k cloned capped bank
    // cap is unchanged after clone
    expect(upgrade.effect[0].bank().toNumber()).toBe(230000);
    expect(upgrade.effect[0].cap().toNumber()).toBe(100000);
    return expect(upgrade.effect[0].output().toNumber()).toBe(100000);
  });

  it('sums costs', function() {
    const game = mkgame({territory:9});
    const upgrade = game.upgrade('expansion');
    expect(_.map(upgrade.sumCost(1), cost => [cost.unit.name, cost.val.toNumber()])).toEqual([['territory',10]]);
    return expect(_.map(upgrade.sumCost(3), cost => [cost.unit.name, cost.val.toNumber()])).toEqual([['territory',94.525]]);
});

  it('notices newly available upgrades', function() {
    const game = mkgame({territory:9});
    const upgrade = game.upgrade('expansion');
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    upgrade.watch(false);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    upgrade.watch(true);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    // we now have money for an upgrade
    game.unit('territory')._addCount(1);
    expect(upgrade.isNewlyUpgradable()).toBe(true);
    // upon disabling isWatched, remove the indicator
    upgrade.watch(false);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    upgrade.watch(true);
    expect(upgrade.isNewlyUpgradable()).toBe(true);
    // stays removed when upgrade bought
    upgrade.buy();
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    // we now have money for another upgrade, which disappears when watch disabled
    game.unit('territory')._addCount(50);
    expect(upgrade.isNewlyUpgradable()).toBe(true);
    upgrade.watch(false);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    // money for a third upgrade does not make the indicator reappear, since we didn't buy upgrade #2
    game.unit('territory')._addCount(150);
    return expect(upgrade.isNewlyUpgradable()).toBe(false);
  });

  xit('doesnt notice invisible upgrades, even if we can afford them. https://github.com/erosson/swarm/issues/94', function() {
    // disabled - this case isn't possible anymore
    const game = mkgame({nest:25000});
    const upgrade = game.upgrade('nesttwin');
    expect(upgrade._lastUpgradeSeen).toEqual(0);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    expect(upgrade.isVisible()).toBe(false);
    expect(upgrade.isCostMet()).toBe(true);
    // even though we can afford it, cannot view invisible upgrades
    upgrade.viewNewUpgrades();
    expect(upgrade._lastUpgradeSeen).toEqual(0);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    expect(upgrade.isVisible()).toEqual(false);
    expect(upgrade.isCostMet()).toEqual(true);
    // we now have visibility, and the indicator!
    game.unit('greaterqueen')._addCount(1);
    expect(upgrade._lastUpgradeSeen).toEqual(0);
    expect(upgrade.isNewlyUpgradable()).toBe(true);
    expect(upgrade.isVisible()).toEqual(true);
    expect(upgrade.isCostMet()).toEqual(true);
    // goes away normally when viewed
    upgrade.viewNewUpgrades();
    expect(upgrade._lastUpgradeSeen).toBeGreaterThan(0);
    expect(upgrade.isNewlyUpgradable()).toBe(false);
    expect(upgrade.isVisible()).toEqual(true);
    return expect(upgrade.isCostMet()).toEqual(true);
  });

  it('rushes meat', function() {
    const game = mkgame({energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, stinger:1});
    const upgrade = game.upgrade('meatrush');
    const unit = game.unit('meat');
    expect(upgrade.effect[0].output().toNumber()).toBe(1 * 7200);
    expect(upgrade.effect[1].output().toNumber()).toBe(100000000000);
    upgrade.buy(1);
    expect(upgrade.count().toNumber()).toBe(1);
    expect(unit.count().toNumber()).toBe(100000007200);
    expect(upgrade.effect[0].output().toNumber()).toBe(1 * 7200);
    return expect(upgrade.effect[1].output().toNumber()).toBe(100000000000);
  });

  it('rushes territory', function() {
    const game = mkgame({energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, swarmling:1});
    const upgrade = game.upgrade('territoryrush');
    const unit = game.unit('territory');
    expect(504).toBe(new Decimal(0.07).times(7200).toNumber()); //stupid floating-point precision
    expect(upgrade.effect[0].output().toNumber()).toBe(504);
    expect(upgrade.effect[1].output().toNumber()).toBe(1000000000);
    upgrade.buy(1);
    expect(upgrade.count().toNumber()).toBe(1);
    expect(unit.count().toNumber()).toBe(1000000000 + 504);
    expect(upgrade.effect[0].output().toNumber()).toBe(504);
    return expect(upgrade.effect[1].output().toNumber()).toBe(1000000000);
  });

  it('rushes larvae', function() {
    const game = mkgame({energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, swarmling:1});
    const upgrade = game.upgrade('larvarush');
    const unit = game.unit('larva');
    expect(upgrade.effect[0].output().toNumber()).toBe(2400);
    expect(upgrade.effect[1].output().toNumber()).toBe(100000);
    upgrade.buy(1);
    expect(upgrade.count().toNumber()).toBe(1);
    expect(unit.count().toNumber()).toBe(102400);
    expect(upgrade.effect[0].output().toNumber()).toBe(2400);
    return expect(upgrade.effect[1].output().toNumber()).toBe(100000);
  });

  it('randomly spawns premutagen when buying hatcheries', function() {
    const game = mkgame({meat:9e+100, premutagen:0});
    const hatchery = game.upgrade('hatchery');
    const effect = hatchery.effect[1]; // mutagen-spawner effect
    const premutagen = game.unit('premutagen');
    hatchery.buy(39);
    expect(premutagen.count().toNumber()).toBe(0);
    const eff = hatchery.effect[1];
    // Random range, but consistent.
    expect(eff.type.name).toBe('addUnitRand');
    const spawned = eff.outputNext().qty.toNumber();
    expect(eff.outputNext().qty.toNumber()).toBe(spawned);
    expect(eff.outputNext().qty.toNumber()).toBe(spawned);
    expect(eff.outputNext().qty.toNumber()).toBe(spawned);
    hatchery.buy(1);
    // first spawn is guaranteed.
    expect(premutagen.count().toNumber()).toBe(spawned);
    expect(premutagen.count().toNumber()).not.toBeGreaterThan(10000);
    return expect(premutagen.count().toNumber()).not.toBeLessThan(7000);
  });

  it('randomly spawns premutagen when buying expansions', function() {
    const game = mkgame({territory:9e+999, premutagen:0});
    const hatchery = game.upgrade('expansion');
    const effect = hatchery.effect[1]; // mutagen-spawner effect
    const premutagen = game.unit('premutagen');
    hatchery.buy(79);
    expect(premutagen.count().toNumber()).toBe(0);
    const eff = hatchery.effect[1];
    // Random range, but consistent.
    expect(eff.type.name).toBe('addUnitRand');
    const spawned = eff.outputNext().qty.toNumber();
    expect(eff.outputNext().qty.toNumber()).toBe(spawned);
    expect(eff.outputNext().qty.toNumber()).toBe(spawned);
    expect(eff.outputNext().qty.toNumber()).toBe(spawned);
    hatchery.buy(1);
    // random range. first spawn is guaranteed.
    expect(premutagen.count().toNumber()).toBe(spawned);
    expect(premutagen.count().toNumber()).not.toBeGreaterThan(10000);
    return expect(premutagen.count().toNumber()).not.toBeLessThan(7000);
  });

  it('rolls different mutagen values after ascending; mutagen spawns depend on date', function() {
    const game = mkgame({invisiblehatchery:1, meat:1e100});
    expect(game.session.state.date.restarted.getTime()).toBe(0);
    const premutagen = game.unit('premutagen');
    game.upgrade('hatchery').buy(80);
    const precount = premutagen.count();
    expect(precount.isZero()).toBe(false); //sanity check

    // rolls change when date.restarted changes
    game.now = new Date(1);
    game.ascend(true);
    expect(game.session.state.date.restarted.getTime()).toBe(1);
    game.unit('meat')._setCount(1e100);
    game.upgrade('hatchery').buy(80);
    const postcount = premutagen.count();
    expect(precount.toNumber()).not.toBe(postcount.toNumber());

    // but change the date back, and mutagen rolls are identical
    game.ascend(true);
    game.session.state.date.restarted = new Date(0);
    game.unit('meat')._setCount(1e100);
    game.upgrade('hatchery').buy(80);
    return expect(precount.toNumber()).toBe(premutagen.count().toNumber());
  });

  it('swarmwarps without changing energy', function() {
    const game = mkgame({energy:50000, nexus:999, invisiblehatchery:1, drone:1, meat:0});
    const upgrade = game.upgrade('swarmwarp');
    const energy = game.unit('energy');
    expect(energy.count().toNumber()).toBe(50000);
    upgrade.buy(1);
    expect(energy.count().toNumber()).toBe(48000);
    upgrade.buy(1);
    return expect(energy.count().toNumber()).toBe(46000);
  });
  it("won't exceed maxlevel in count()", function() {
    const game = mkgame({});
    const upgrade = game.upgrade('achievementbonus');
    expect(upgrade.type.maxlevel).toBe(5);
    expect(upgrade.count().toNumber()).toBe(0);
    upgrade._setCount(999);
    return expect(upgrade.count().toNumber()).toBe(5);
  });

  it("won't buy more than maxlevel", function() {
    const game = mkgame({meat:1e300, territory:1e300});
    const upgrade = game.upgrade('achievementbonus');
    expect(upgrade.type.maxlevel).toBe(5);

    expect(upgrade.count().toNumber()).toBe(0);
    expect(upgrade.maxCostMet().toNumber()).toBe(5);
    upgrade._setCount(1);
    expect(upgrade.count().toNumber()).toBe(1);
    expect(upgrade.maxCostMet().toNumber()).toBe(4);
    upgrade._setCount(3);
    expect(upgrade.count().toNumber()).toBe(3);
    return expect(upgrade.maxCostMet().toNumber()).toBe(2);
  });

  it("knows autobuyable upgrades depend on watched status", function() {
    const game = mkgame({});
    expect(game.upgrade('droneprod').isAutobuyable()).toBe(true);
    expect(game.upgrade('dronetwin').isAutobuyable()).toBe(true);
    expect(game.upgrade('swarmlingtwin').isAutobuyable()).toBe(true);
    expect(game.upgrade('mutatemeat').isAutobuyable()).toBe(false);
    game.upgrade('dronetwin').watch(false);
    expect(game.upgrade('dronetwin').isAutobuyable()).toBe(false);
    game.upgrade('dronetwin').watch(true);
    return expect(game.upgrade('dronetwin').isAutobuyable()).toBe(true);
  });

  it("calculates asymptotic stats multiplicatively, not additively. #264", function() {
    const game = mkgame({nexus:5, moth:1e1000, mutantnexus:1e1000});
    const energyprod = game.unit('energy').velocity().toNumber();
    expect(energyprod).toBeGreaterThan(1.9);
    return expect(energyprod).toBeLessThan(2.1);
  });

  it("fetches empty stats", function() {
    const game = mkgame({});
    return expect(() => game.upgrade('nexus1').statistics()).not.toThrow();
  });

  return it("buys-all, accounting for watch points", function() {
    const game = mkgame({});
    const up = game.upgrade('expansion');
    const unit = game.unit('territory');
    expect(game.availableAutobuyUpgrades().length).toBe(0);
    unit._setCount(10);
    expect(game.availableAutobuyUpgrades().length).toBe(1);
    unit._setCount(9);
    expect(game.availableAutobuyUpgrades().length).toBe(0);

    up.watch(2);
    expect(game.availableAutobuyUpgrades().length).toBe(0);
    unit._setCount(10);
    expect(game.availableAutobuyUpgrades().length).toBe(0);
    unit._setCount(20);
    expect(game.availableAutobuyUpgrades().length).toBe(1);
    unit._setCount(19);
    return expect(game.availableAutobuyUpgrades().length).toBe(0);
  });
});
