'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:bignum
 # @function
 # @description
 # # bignum
 # Filter in the swarmApp.
###
angular.module('swarmApp').factory 'bignumFormatter', (options) ->
  f = new numberformat.Formatter
    backend: 'decimal.js'
    # some formats have different names in the numberformat defaults
    format: 'standard-decimal'
    rounding: Decimal.ROUND_FLOOR
    formats: _.extend {}, _.pick(numberformat.Formats, 'hybrid', 'engineering'),
      'standard-decimal': numberformat.Formats.standard,
      'scientific-e': numberformat.Formats.scientific,
  (opts={}) ->
    ret = (num, maxSmall=0, opts2={}) ->
      opts = _.extend(opts, opts2)
      # not sure where we're getting undefined inputs from, but the stack trace
      # is useless and I can't be bothered to hunt them down in a game I'm not
      # actively working on anymore
      if (num == undefined) then return ''
      # actual formatting - just use swarm-numberformat
      opts.format = options.notation()
      # maxSmall is for places where we need small decimals, like energy
      opts.maxSmall = maxSmall
      ret = f.format(num, opts)
      return ret
    # http://blog.thoughtram.io/angularjs/2014/11/19/exploring-angular-1.3-stateful-filters.html
    # TODO: make this stateless, with params, so angular can optimize. For now, $stateful keeps
    # the old behavior and avoids overcaching.
    ret.$stateful = true
    return ret

angular.module('swarmApp').filter 'bignum', (bignumFormatter) ->
  bignumFormatter {flavor: 'short'}

angular.module('swarmApp').filter 'longnum', (bignumFormatter) ->
  bignumFormatter {flavor: 'full', sigfigs:6, minsuffix:1e6}

angular.module('swarmApp').filter 'ceil', ->
  (num) -> Math.ceil num

angular.module('swarmApp').filter 'percent', ($filter) ->
  (num, opts={}) ->
    if _.isNumber opts
      opts = {places:opts}
    opts.places ?= 0
    dec = new Decimal num+''
    if opts.plusOne
      dec = dec.minus(1)
    dec = dec.times(100)
    if opts.floor
      dec = dec.floor()
    if opts.longnum
      dec = $filter('longnum')(dec)
    else
      dec = $filter('number')(dec.toNumber(), opts.places)
    return "#{dec}%"

# These are used by the input parser
angular.module('swarmApp').constant 'numberSuffixesShort',
  numberformat.Formats.standard.suffixGroups.short
angular.module('swarmApp').constant 'numberSuffixesLong',
  numberformat.Formats.standard.suffixGroups.full
