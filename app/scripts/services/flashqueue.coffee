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
angular.module('swarmApp').factory 'FlashQueue', ($log, $timeout, util, env) -> class FlashQueue
  constructor: (@showTime=5000, @fadeTime=1000) ->
    @queue = []
    @_state = 'invisible'
    @_timeout = null
  push: (message) ->
    # no prod flashqueues, just in case - achievements aren't activiated yet
    if env.achievementsEnabled
      @queue.push message
      @animate() #animate will ignore this if there's other items ahead of us
  animate: ->
    if @_state == 'invisible' and @queue.length > 0
      $log.debug 'flashqueue beginning animation', @get()
      @_state = 'visible'
      @_timeout = $timeout (=>
        @_state = 'fading'
        @_timeout = $timeout (=>
          $log.debug 'flashqueue ending animation', @get()
          @_state = 'invisible'
          @queue.shift()
          @animate()
        ), @fadeTime
      ), @showTime
  isVisible: ->
    env.achievementsEnabled and @_state == 'visible'
  get: ->
    @queue[0]

angular.module('swarmApp').factory 'flashqueue', ($log, FlashQueue, $rootScope) ->
  queue = new FlashQueue()

  # TODO this really shouldn't be attached ot the main flashqueue...
  $rootScope.$on 'achieve', (event, achievement) ->
    $log.debug 'achievement flashqueue pushing achievement', achievement
    queue.push achievement

  return queue
