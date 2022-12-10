'use strict'

angular.module('swarmApp').factory 'parseNumber', ($log, numberSuffixesShort, numberSuffixesLong) ->
  DecCeil = Decimal.clone rounding: Decimal.ROUND_CEIL

  suffixToExp = {}
  for suffixes in [numberSuffixesShort, numberSuffixesLong]
    for suffix, index in suffixes
      if suffix
        # no dupe suffixes, #517
        if suffixToExp[suffix.toLowerCase()]?
          throw new Error "duplicate parsenumber suffix: #{suffix}"
        suffixToExp[suffix.toLowerCase()] = {index:index, exp:index*3, replace:"e#{index*3}"}
  (value0, unit) ->
    # stringify
    value = (value0+'')?.replace ',', ''
    # percentage of max buyable
    if (match=/%$/.exec value)?
      try
        percent = Decimal.min 100, Decimal.max 0, value.replace '%', ''
      catch e
        percent = new Decimal 0
      value = unit.maxCostMet percent.dividedBy 100
      $log.debug 'parse percent', value0, percent, value+''
    # replace suffixes ('billion')
    if (match=/\ ?[a-zA-Z]+/.exec value)?
      if match.length > 0 and (exp=suffixToExp[match[0].toLowerCase()])?
        value = value.replace match[0], exp.replace
        $log.debug 'parse suffix', value0, value
      else
        $log.debug 'parse suffix (invalid)', value0, value, match
    # exact-value, accounting for twins
    if (notwins=/^\=/.exec value)?
      value = value.replace '=', ''
    # target-value, buy enough units to have this many afterward
    else if (target=/^@/.exec value)?
      notwins = true
      value = value.replace '@', ''
    try
      # DecCeil is a Decimal that rounds up, avoidiing precision errors like
      # #671. `.ceil()` isn't good enough for large numbers here.
      ret = DecCeil.max 1, value
      if target
        ret = DecCeil.max 1, ret.minus(unit.count())
        $log.debug 'parse target', value0, ret+'', '-'+unit.count()
      if notwins
        # twins round up - buy at least as many as requested.
        # this means "=12.5"x2 buys 26 units, not 24; no big deal either way
        ret = ret.dividedBy(unit.twinMult()).ceil()
        $log.debug 'parse twins', value0, ret+'', 'x'+unit.twinMult()
      else
        # normally, decimal numbers round down
        ret = ret.floor()
      # return to normal rounding.
      ret = new Decimal ret
      if ret.isFinite() and not ret.isNaN()
        return ret
    catch e
      # parse error, return undefined. this is user input, don't fuss with logging
      $log.debug 'user input parse error', e
