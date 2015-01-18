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
    # hacky 0.2.11 fix - for a short time, nexus upgrades didn't
    do ->
      for i in [1..5]
        if game.upgrade("nexus#{i}").count() > 0 and game.unit('nexus').count() < i
          $log.debug 'nexusfix', i, game.upgrade("nexus#{i}").count(), game.unit('nexus').count()
          $log.info 'fixed nexus count', i
          game.unit('nexus')._setCount i

    # grant mutagen for old saves, created before mutagen existed
    do ->
      premutagen = game.unit 'premutagen'
      ascension = game.unit 'ascension'
      hatchery = game.upgrade 'hatchery'
      expansion = game.upgrade 'expansion'
      minlevel = game.unit('invisiblehatchery').stat 'random.minlevel'
      # at minlevel hatcheries/expos, premutagen is always granted. if it wasn't - no ascensions and no premutagen -
      # this must be an old save, they got the upgrades before mutagen existed.
      if premutagen.count() == ascension.count() == 0 and (hatchery.count() >= minlevel or expansion.count() >= minlevel)
        $log.info 'backfilling mutagen for old save'
        for up in [hatchery, expansion]
          for i in [0...up.count()]
            for e in up.effect
              e.onBuy i + 1
      else
        $log.debug 'no mutagen backfill necessary'

    $log.debug 'backfill success'

angular.module('swarmApp').factory 'backfill', (Backfill) -> new Backfill()
