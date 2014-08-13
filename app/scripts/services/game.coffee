'use strict'

###*
 # @ngdoc service
 # @name swarmApp.game
 # @description
 # # game
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'Game', (dt, unittypes) -> class Game
  constructor: (@session) ->
    #for unittype in @unittypes.list
    #  session.unittypes[unittype.name] ?= unittype.init or 0

  diffMillis: (now=new Date()) ->
    now.getTime() - @session.date.saved

  diffTicks: (now) ->
    millis = @diffMillis now
    return millis / 1000 / dt

  gainsOne: (ticks, gen) ->
    # Calculate rate of offline gains for a single resource.
    # "Generation": calculate gains for that resource's children's children.
    # Gains should match pascal's triangle.
    # https://en.wikipedia.org/wiki/Pascal's_triangle
    # This post explains it: http://www.reddit.com/r/incremental_games/comments/2co88i/ive_been_playing_adventure_capitalist_for_the/cji9fmm
    # Calculating pascal's triangle is just ticks-combo-gen:
    # https://en.wikipedia.org/wiki/Pascal's_triangle#Combinations
    #
    # Bug: decimal rates. Gen 2 can create 1 full unit before gen 1 finishes 1 full unit. Eh... close enough.
    if gen > ticks
      return 0
    return math.combinations ticks, gen

  rawCount: (name) ->
    @session.unittypes[name] ? 0

  children: (unittype) ->
    ret = {}
    count = @rawCount unittype.name
    for child in unittype.prod
      #rate = child.val # TODO insert bonuses here
      ret[child.unittype.name] =
        name: child.unittype.name
        gen: 1
        rate: 1 # TODO
      for name, descendent of @children child.unittype
        console.assert not ret[name]?, 'double children not supported yet'
        ret[name] = descendent
        descendent.gen += 1
        #descendent.rate *= rate
    return ret

  gainsTableOne: (unittype, ticks) ->
    ret = {}
    count = @rawCount unittype.name
    for name, child of @children unittype
      ret[name] = count * child.rate * @gainsOne ticks, child.gen
    return ret

  gainsTable: (ticks) ->
    ret = {}
    for unittype in unittypes.list
      ret[unittype.name] = @rawCount unittype.name
    for unittype in unittypes.list
      gains = @gainsTableOne unittype, ticks
      for name, val of gains
        ret[name] += val
    return ret

angular.module('swarmApp').factory 'game', (Game, session) ->
  return new Game session
