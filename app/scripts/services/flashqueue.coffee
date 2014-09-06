'use strict'

###*
 # @ngdoc service
 # @name swarmApp.flashqueue
 # @description
 # # flashqueue
 # Factory in the swarmApp.
 #
 # Achievement UI notification and animation.
###
angular.module('swarmApp').factory 'FlashQueue', ($timeout, util, env) -> class FlashQueue
  constructor: (@showTime=5000, @fadeTime=1000) ->
    @queue = []
    @_state = 'invisible'
    @_timeout = null
  push: (message) ->
    @queue.push message
    # no prod flashqueues, just in case - achievements aren't activiated yet
    if env.achievementsEnabled and @queue.length == 1 #just pushed the only item
      @animate()
  animate: ->
    if @_state == 'invisible'
      @_state = 'visible'
      @_timeout = $timeout (=>
        @_state = 'fading'
        @_timeout = $timeout (=>
          @_state = 'invisible'
          @queue.shift()
          if @queue.length
            @animate()
        ), @fadeTime
      ), @showTime
  isVisible: ->
    env.achievementsEnabled and @_state == 'visible'
  get: ->
    @queue[0]

angular.module('swarmApp').factory 'flashqueue', (FlashQueue) ->
  new FlashQueue()
