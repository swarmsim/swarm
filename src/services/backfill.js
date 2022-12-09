/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';

/**
 * @ngdoc service
 * @name swarmApp.Backfill
 * @description
 * # Backfill
 *
 * fix up old/broken save data at load time
*/
angular.module('swarmApp').factory('Backfill', function($log, achievementslistener) { let Backfill;
return Backfill = class Backfill {
  run(game) {
    // grant mutagen for old saves, created before mutagen existed
    (function() {
      const premutagen = game.unit('premutagen');
      const ascension = game.unit('ascension');
      const hatchery = game.upgrade('hatchery');
      const expansion = game.upgrade('expansion');
      const minlevelHatch = game.unit('invisiblehatchery').stat('random.minlevel.hatchery');
      const minlevelExpo = game.unit('invisiblehatchery').stat('random.minlevel.expansion');
      // at minlevel hatcheries/expos, premutagen is always granted. if it wasn't - no ascensions and no premutagen -
      // this must be an old save, they got the upgrades before mutagen existed.
      if (premutagen.count().isZero() && ascension.count().isZero() && (hatchery.count().greaterThanOrEqualTo(minlevelHatch) || expansion.count().greaterThanOrEqualTo(minlevelExpo))) {
        $log.info('backfilling mutagen for old save');
        return [hatchery, expansion].map((up) =>
          // toNumber is safe; old saves won't exceed 1e300 expansions/hatcheries
          __range__(0, up.count().toNumber(), false).map((i) =>
            Array.from(up.effect).map((e) =>
              e.onBuy(new Decimal(i + 1)))));
      } else {
        return $log.debug('no mutagen backfill necessary');
      }
    })();

    // grant free respecs for all saves created before respecs existed
    (function() {
      const respec = game.unit('freeRespec');
      if (!respec.isCountInitialized()) {
        return respec._setCount(respec.unittype.init);
      }
    })();

    // restore lost ascension count. https://github.com/erosson/swarm/issues/431
    (function() {
      const ascension = game.unit('ascension');
      const stats = ascension.statistics();
      if (new Decimal((stats != null ? stats.num : undefined) != null ? (stats != null ? stats.num : undefined) : 0).greaterThan(ascension.count()) && ascension.count().isZero()) {
        $log.info('backfill lost ascension tally', ascension.count()+'', stats.num);
        return ascension._setCount(stats.num);
      }
    })();
    
    // apply all new achievements. https://github.com/swarmsim/swarm/issues/701
    // On second thought, wait for them to buy a unit so achievement popups appear
    //achievementslistener.achieveUnit()

    return $log.debug('backfill success');
  }
};
 });

angular.module('swarmApp').factory('backfill', Backfill => new Backfill());

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}