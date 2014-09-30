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
  (suffixes, opts={}) ->
    opts.sigfigs ?= 3
    # special case: 99k or less looks nicer with the 'k' omitted
    opts.minsuffix ?= 1e5
    (num, floorlimit=0) ->
      if !num
        return num
      if num < floorlimit
        return num.toPrecision(opts.sigfigs).replace /\.?0+$/, ''
      num = Math.floor num
      if num < opts.minsuffix
        # sadly, num.toLocaleString() does not work in unittests. node vs browser?
        # toLocaleString would be nice for foreign users, but my unittests are
        # more important, sorry. Maybe later.
        return numeral(num).format '0,0'
      # nope. Numeral only supports up to trillions, so have to do this myself :(
      # return numeral(num).format '0.[00]a'
      # http://mathforum.org/library/drmath/view/59154.html
      index = Math.floor Math.log(num) / Math.log 1000
      if options.notation() == 'scientific-e' or index >= suffixes.length
        # too big for any suffix :(
        # TODO: exponent groups of 3? 1e30, 10e30, 100e30, 1e33, ...
        #return num.toExponential(2).replace(/\.?0+e/, 'e').replace 'e+', 'e'
        return num.toExponential(opts.sigfigs-1).replace 'e+', 'e'
      else
        suffix = suffixes[index]
      num /= Math.pow 1000, index
      # regex removes trailing zeros and decimal
      # based on http://stackoverflow.com/a/16471544
      #return "#{num.toPrecision(3).replace(/\.([^0]*)0+$/, '.$1').replace(/\.$/, '')}#{suffix}"
      # turns out it's very distracting to have the number length change, so keep trailing zeros
      return "#{num.toPrecision(opts.sigfigs).replace(/\.$/, '')}#{suffix}"

angular.module('swarmApp').filter 'bignum', (bignumFormatter) ->
  # These aren't official abbreviations, apparently, can't find them on google
  # for anything but cookie clicker. Other games have used them though.
  # TODO We should probably ask before stealing Derivative Clicker's abbrevs.
  bignumFormatter ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc']

angular.module('swarmApp').filter 'longnum', (bignumFormatter) ->
  # http://home.kpn.nl/vanadovv/BignumbyN.html
  # http://mathforum.org/library/drmath/view/59154.html
  bignumFormatter [''
                   ' thousand'
                   ' million'
                   ' billion'
                   ' trillion'
                   ' quadrillion'
                   ' quintillion'
                   ' sextillion'
                   ' septillion'
                   ' octillion'
                   ' nonillion'
                   ' decillion'
                   ' undecillion'
                   ' duodecillion'
                   ' tredecillion'
                   ' quattuordecillion'
                   ' quinquadecillion'
                   ' sedecillion' # google says this is actually legit, not a typo for 'sexdecillion'
                   ' septendecillion'
                   ' octodecillion'
                   ' novendecillion'
                   ' vigintillion'
                   ' unvigintillion'
                   ' duovigintillion'
                   ' tresvigintillion'
                   ' quattuorvigintillion'
                   ' quinquavigintillion'
                   ' sesvigintillion'
                   ' septemvigintillion'
                   ' octovigintillion'
                   ' novemvigintillion'
                   ' trigintillion'
                   ' untrigintillion'
                   ' duotrigintillion'
                   ' trestrigintillion'
                   ' quattuortrigintillion'
                   ' quinquatrigintillion'
                   ' sestrigintillion'
                   ' septentrigintillion'
                   ' octotrigintillion'
                   ' noventrigintillion'
                   ' quadragintillion'
                   ' unquadragintillion'
                   ' duoquadragintillion'
                   ' tresquadragintillion'
                   ' quattuorquadragintillion'
                   ' quinquaquadragintillion'
                   ' sesquadragintillion'
                   ' septenquadragintillion'
                   ' octoquadragintillion'
                   ' novenquadragintillion'
                   ' quinquagintillion'
                   ' unquinquagintillion'
                   ' duoquinquagintillion'
                   ' tresquinquagintillion'
                   ' quattuorquinquagintillion'
                   ' quinquaquinquagintillion'
                   ' sesquinquagintillion'
                   ' septenquinquagintillion'
                   ' octoquinquagintillion'
                   ' novenquinquagintillion'
                   ' sexagintillion'
                   ' unsexagintillion'
                   ' duosexagintillion'
                   ' tresexagintillion'
                   ' quattuorsexagintillion'
                   ' quinquasexagintillion'
                   ' sesexagintillion'
                   ' septensexagintillion'
                   ' octosexagintillion'
                   ' novensexagintillion'
                   ' septuagintillion'
                   ' unseptuagintillion'
                   ' duoseptuagintillion'
                   ' treseptuagintillion'
                   ' quattuorseptuagintillion'
                   ' quinquaseptuagintillion'
                   ' seseptuagintillion'
                   ' septenseptuagintillion'
                   ' octoseptuagintillion'
                   ' novenseptuagintillion'
                   ' octogintillion'
                   ' unoctogintillion'
                   ' duooctogintillion'
                   ], {sigfigs:6, minsuffix:1e6}
