'use strict'

###*
 # @ngdoc service
 # @name swarmApp.util
 # @description
 # # util
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'util', ($log, $rootScope, $timeout, $animate) -> new class Util
  sum: (ns) -> _.reduce ns, ((a,b) -> a+b), 0
  assert: (val, message...) ->
    if not val
      $log.error "Assertion error", message...
      $rootScope.$emit 'assertionFailure', message
      throw new Error message
    return val
  error: (message...) ->
    $rootScope.$emit 'error', message

  requestAnimationFrame: (fn) ->
    return window.requestAnimationFrame ->
      fn()
      $rootScope.$digest()
  animateController: ($scope, opts={}) ->
    game = opts.game ? $scope.game
    options = opts.options ? $scope.options
    timeout = null
    raf = null
    do animateFn = =>
      # timeouts instead of intervals is less precise, but it automatically adjusts to options menu fps changes
      # intervals could work if we watched for options changes, but why bother?
      # actually, rAF is almost always better, but don't drop support for manually-setting fps because it's what people are used to
      if options.fpsAuto() && !!window.requestAnimationFrame
        #$log.debug 'rAF'
        raf = @requestAnimationFrame animateFn
        timeout = null
      else
        #$log.debug 'timeout', options.fpsSleepMillis()
        timeout = $timeout animateFn, options.fpsSleepMillis()
        raf = null
      game.tick()
      $rootScope.$emit 'tick', game
    $scope.$on '$destroy', ->
      $timeout.cancel timeout
      window.cancelAnimationFrame raf

  isWindowFocused: (default_=true) ->
    # true if browser tab focused, false if tab unfocused. NOT 100% RELIABLE! If we can't tell, default == focused (true).
    # err, default != hidden
    return not (document.hidden?() ? not default_)

  isFloatEqual: (a, b, tolerance=0) ->
    return Math.abs(a - b) <= tolerance

  # http://stackoverflow.com/questions/13262621
  utcdoy: (ms) ->
    t = moment.utc(ms)
    days = parseInt(t.format 'DDD')-1
    daystr = if days > 0 then "#{days}d " else ''
    "#{daystr}#{t.format 'H\\h mm:ss.SSS'}"
