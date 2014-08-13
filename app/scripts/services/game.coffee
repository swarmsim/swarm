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

  diffSeconds: (now) ->
    @diffMillis(now) / 1000

  rawCount: (name) ->
    @session.unittypes[name] ? 0

  _gainsPath: (path, secs) ->
    producer = path[0]
    count = @rawCount producer.name
    gen = path.length
    c = math.factorial gen
    # Bonus for ancestor to produced-child == product of all bonuses along the path
    # (intuitively, if velocity and velocity-changes are doubled, acceleration is doubled too)
    # Quantity of buildings along the path do not matter, they're calculated separately.
    bonus = 1
    for ancestor in path
      bonus *= 1 # TODO: calculate bonuses
    return count * bonus / c * math.pow secs, gen

  count: (unitname, secs=@diffSeconds()) ->
    unittype = unittypes.byName[unitname]
    #console.log 'countin', unitname, unittype.producerPath
    console.assert unittype
    gains = @rawCount unittype.name
    for pname, path of unittype.producerPath
      #console.log 'gains', unittype.name, path[0].name, @_gainsPath path, secs
      gains += @_gainsPath path, secs
    return gains

  counts: (secs) ->
    _.mapValues unittypes.byName, (unittype, name) =>
      @count name, secs

angular.module('swarmApp').factory 'game', (Game, session) ->
  return new Game session
