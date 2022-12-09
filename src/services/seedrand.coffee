'use strict'

###*
 # @ngdoc service
 # @name swarmApp.seedrand
 # @description
 # # seedrand
 #
 # Deterministic serializable random numbers.
 # Fights savestate scumming that would occur with math.rand().
###
angular.module('swarmApp').service 'seedrand', (session) -> new class SeedRand
  constructor: ->
  # normal seeding uses session.date.started, but let unittests override it
  mkseed: (seedstring, baseseed=session.state.date.started) ->
    "#{baseseed}:#{seedstring}"
  rng: (seedstring, baseseed=null) ->
    seed = @mkseed seedstring, baseseed
    # Math.seedrandom from https://github.com/davidbau/seedrandom
    new Math.seedrandom seed
  rand: (seedstring, baseseed=null) ->
    # create a seeded rng, use it once, and throw it away.
    # `seedrand.rand(str)` will always return the same result for constant `str`.
    return @rng(seedstring, baseseed)()
