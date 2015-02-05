'use strict'

###*
 # @ngdoc service
 # @name swarmApp.Backfill
 # @description
 # # Backfill
 #
 # fix up old/broken save data at load time
###
angular.module('swarmApp').factory 'Backfill', ($log) -> class Backfill
  run: (game) ->
    # grant mutagen for old saves, created before mutagen existed
    do ->
      premutagen = game.unit 'premutagen'
      ascension = game.unit 'ascension'
      hatchery = game.upgrade 'hatchery'
      expansion = game.upgrade 'expansion'
      minlevelHatch = game.unit('invisiblehatchery').stat 'random.minlevel.hatchery'
      minlevelExpo = game.unit('invisiblehatchery').stat 'random.minlevel.expansion'
      # at minlevel hatcheries/expos, premutagen is always granted. if it wasn't - no ascensions and no premutagen -
      # this must be an old save, they got the upgrades before mutagen existed.
      if premutagen.count().isZero() and ascension.count().isZero() and (hatchery.count().greaterThanOrEqualTo(minlevelHatch) or expansion.count().greaterThanOrEqualTo(minlevelExpo))
        $log.info 'backfilling mutagen for old save'
        for up in [hatchery, expansion]
          # toNumber is safe; old saves won't exceed 1e300 expansions/hatcheries
          for i in [0...up.count().toNumber()]
            for e in up.effect
              e.onBuy new Decimal i + 1
      else
        $log.debug 'no mutagen backfill necessary'

    $log.debug 'backfill success'

angular.module('swarmApp').factory 'backfill', (Backfill) -> new Backfill()
