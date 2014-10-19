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
angular.module('swarmApp').factory 'FlashQueue', ($log, $timeout, util) -> class FlashQueue
  constructor: (@showTime=5000, @fadeTime=1000) ->
    @queue = []
    @_state = 'invisible'
    @_timeout = null
  push: (message) ->
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
    @_state == 'visible'
  get: ->
    @queue[0]
  clear: ->
    $log.debug 'flashqueue clearing animation'
    @queue.length = 0
    if @_timeout
      $timeout.cancel @_timeout
    @_state = 'invisible'

angular.module('swarmApp').factory 'flashqueue', ($log, FlashQueue, $rootScope) ->
  queue = new FlashQueue 5000

  # TODO this really shouldn't be attached ot the main flashqueue...
  $rootScope.$on 'achieve', (event, achievement) ->
    $log.debug 'achievement flashqueue pushing achievement', achievement
    queue.push achievement

  return queue

angular.module('swarmApp').factory 'undoqueue', ($log, FlashQueue, $rootScope) ->
  queue = new FlashQueue 10000

  $rootScope.$on 'command', (event, command) ->
    $log.debug 'undo flashqueue pushing command', command
    queue.clear()
    queue.push command

  return queue
