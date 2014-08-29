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
    # 99k or less looks nicer with the 'k' omitted
    if num < 100000
      # sadly, num.toLocaleString() does not work in unittests. node vs browser?
      # toLocaleString would be nice for foreign users, but my unittests are
      # more important, sorry. Maybe later.
      return numeral(num).format '0,0'
    # nope. Numeral only supports up to trillions, so have to do this myself :(
    # return numeral(num).format '0.[00]a'
    suffixes = ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc']
    index = Math.floor Math.log(num) / Math.log 1000
    if index >= suffixes.length
      # too big for any suffix :(
      # TODO: exponent groups of 3? 1e30, 10e30, 100e30, 1e33, ...
      return num.toExponential(2)
    # has a valid suffix!
    suffix = suffixes[index]
    num /= Math.pow 1000, index
    # regex removes trailing zeros and decimal
    # based on http://stackoverflow.com/a/16471544
    return "#{num.toPrecision(3).replace(/\.([^0]*)0+$/, '.$1').replace(/\.$/, '')}#{suffix}"
