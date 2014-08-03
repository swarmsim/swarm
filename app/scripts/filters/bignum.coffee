'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:bignum
 # @function
 # @description
 # # bignum
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'bignum', ->
  (num) ->
    num = Math.floor num
    if num < 100000
      # TODO this doesn't work in node/unittests
      return num.toLocaleString()
    # TODO better formatting for big numbers
    return num.toExponential(2)
