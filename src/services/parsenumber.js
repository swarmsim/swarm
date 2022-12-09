/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';

angular.module('swarmApp').factory('parseNumber', function($log, numberSuffixesShort, numberSuffixesLong) {
  const DecCeil = Decimal.clone({rounding: Decimal.ROUND_CEIL});

  const suffixToExp = {};
  for (var suffixes of [numberSuffixesShort, numberSuffixesLong]) {
    for (var index = 0; index < suffixes.length; index++) {
      var suffix = suffixes[index];
      if (suffix) {
        // no dupe suffixes, #517
        if (suffixToExp[suffix.toLowerCase()] != null) {
          throw new Error(`duplicate parsenumber suffix: ${suffix}`);
        }
        suffixToExp[suffix.toLowerCase()] = {index, exp:index*3, replace:`e${index*3}`};
      }
    }
  }
  return function(value0, unit) {
    // stringify
    let e, match, notwins, target;
    let value = __guard__((value0+''), x => x.replace(',', ''));
    // percentage of max buyable
    if ((match=/%$/.exec(value)) != null) {
      let percent;
      try {
        percent = Decimal.min(100, Decimal.max(0, value.replace('%', '')));
      } catch (error) {
        e = error;
        percent = new Decimal(0);
      }
      value = unit.maxCostMet(percent.dividedBy(100));
      $log.debug('parse percent', value0, percent, value+'');
    }
    // replace suffixes ('billion')
    if ((match=/\ ?[a-zA-Z]+/.exec(value)) != null) {
      let exp;
      if ((match.length > 0) && ((exp=suffixToExp[match[0].toLowerCase()]) != null)) {
        value = value.replace(match[0], exp.replace);
        $log.debug('parse suffix', value0, value);
      } else {
        $log.debug('parse suffix (invalid)', value0, value, match);
      }
    }
    // exact-value, accounting for twins
    if ((notwins=/^\=/.exec(value)) != null) {
      value = value.replace('=', '');
    // target-value, buy enough units to have this many afterward
    } else if ((target=/^@/.exec(value)) != null) {
      notwins = true;
      value = value.replace('@', '');
    }
    try {
      // DecCeil is a Decimal that rounds up, avoidiing precision errors like
      // #671. `.ceil()` isn't good enough for large numbers here.
      let ret = DecCeil.max(1, value);
      if (target) {
        ret = DecCeil.max(1, ret.minus(unit.count()));
        $log.debug('parse target', value0, ret+'', '-'+unit.count());
      }
      if (notwins) {
        // twins round up - buy at least as many as requested.
        // this means "=12.5"x2 buys 26 units, not 24; no big deal either way
        ret = ret.dividedBy(unit.twinMult()).ceil();
        $log.debug('parse twins', value0, ret+'', 'x'+unit.twinMult());
      } else {
        // normally, decimal numbers round down
        ret = ret.floor();
      }
      // return to normal rounding.
      ret = new Decimal(ret);
      if (ret.isFinite() && !ret.isNaN()) {
        return ret;
      }
    } catch (error1) {
      // parse error, return undefined. this is user input, don't fuss with logging
      e = error1;
      return $log.debug('user input parse error', e);
    }
  };
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}