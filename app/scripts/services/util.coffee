'use strict'

###*
 # @ngdoc service
 # @name swarmApp.util
 # @description
 # # util
 # Service in the swarmApp.
###
angular.module('swarmApp').factory 'util', ($log, $rootScope, $interval) -> new class Util
  constructor: ->
  sum: (ns) -> _.reduce ns, ((a,b) -> a+b), 0
  assert: (val, message...) ->
    if not val
      $log.error "Assertion error", message...
      $rootScope.$emit 'assertionFailure', message
      throw new Error message
    return val
  error: (message...) ->
    $rootScope.$emit 'error', message
  walk: (obj, fn, path="", rets=[]) ->
    ret = fn obj, path
    if ret?
      rets.push ret
    if _.isArray obj
      for elem, index in obj
        @walk elem, fn, "#{path}[#{index}]", rets
    else if _.isObject obj
      for key, prop of obj
        @walk prop, fn, "#{path}.#{key}", rets
    return rets
  # For use with lodash _.memoize
  clearMemoCache: (memoizedFns...) ->
    for fn in memoizedFns
      for key, val of fn.cache
        delete fn.cache[key]

  animateController: ($scope, opts={}) ->
    game = opts.game ? $scope.game
    options = opts.options ? $scope.options
    animatePromise = $interval (=>game.tick()), options.fpsSleepMillis()
    $scope.$on '$destroy', =>
      $interval.cancel animatePromise

