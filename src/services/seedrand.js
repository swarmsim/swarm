/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc service
 * @name swarmApp.seedrand
 * @description
 * # seedrand
 *
 * Deterministic serializable random numbers.
 * Fights savestate scumming that would occur with math.rand().
*/
angular.module('swarmApp').service('seedrand', function(session) { let SeedRand;
return new (SeedRand = class SeedRand {
  constructor() {}
  // normal seeding uses session.date.started, but let unittests override it
  mkseed(seedstring, baseseed) {
    if (baseseed == null) { baseseed = session.state.date.started; }
    return `${baseseed}:${seedstring}`;
  }
  rng(seedstring, baseseed=null) {
    const seed = this.mkseed(seedstring, baseseed);
    // Math.seedrandom from https://github.com/davidbau/seedrandom
    return new Math.seedrandom(seed);
  }
  rand(seedstring, baseseed=null) {
    // create a seeded rng, use it once, and throw it away.
    // `seedrand.rand(str)` will always return the same result for constant `str`.
    return this.rng(seedstring, baseseed)();
  }
});
 });
