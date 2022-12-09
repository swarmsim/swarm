/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';

/**
 * @ngdoc service
 * @name swarmApp.util
 * @description
 * # util
 * Service in the swarmApp.
*/
angular.module('swarmApp').factory('util', function($log, $rootScope, $timeout, $animate) { let Util;
return new (Util = class Util {
  sum(ns) { return _.reduce(ns, ((a, b) => a+b), 0); }
  assert(val, ...message) {
    if (!val) {
      $log.error("Assertion error", ...Array.from(message));
      $rootScope.$emit('assertionFailure', message);
      throw new Error(message);
    }
    return val;
  }
  error(...message) {
    return $rootScope.$emit('error', message);
  }

  requestAnimationFrame(fn) {
    return window.requestAnimationFrame(function() {
      fn();
      return $rootScope.$digest();
    });
  }
  animateController($scope, opts) {
    let animateFn;
    if (opts == null) { opts = {}; }
    const game = opts.game != null ? opts.game : $scope.game;
    const options = opts.options != null ? opts.options : $scope.options;
    let timeout = null;
    let raf = null;
    (animateFn = () => {
      // timeouts instead of intervals is less precise, but it automatically adjusts to options menu fps changes
      // intervals could work if we watched for options changes, but why bother?
      // actually, rAF is almost always better, but don't drop support for manually-setting fps because it's what people are used to
      if (options.fpsAuto() && !!window.requestAnimationFrame) {
        //$log.debug 'rAF'
        raf = this.requestAnimationFrame(animateFn);
        timeout = null;
      } else {
        //$log.debug 'timeout', options.fpsSleepMillis()
        timeout = $timeout(animateFn, options.fpsSleepMillis());
        raf = null;
      }
      game.tick();
      return $rootScope.$emit('tick', game);
    })();
    return $scope.$on('$destroy', function() {
      $timeout.cancel(timeout);
      return window.cancelAnimationFrame(raf);
    });
  }

  isWindowFocused(default_) {
    // true if browser tab focused, false if tab unfocused. NOT 100% RELIABLE! If we can't tell, default == focused (true).
    // err, default != hidden
    let left;
    if (default_ == null) { default_ = true; }
    return !((left = (typeof document.hidden === 'function' ? document.hidden() : undefined)) != null ? left : !default_);
  }

  isFloatEqual(a, b, tolerance) {
    if (tolerance == null) { tolerance = 0; }
    return Math.abs(a - b) <= tolerance;
  }

  // http://stackoverflow.com/questions/13262621
  utcdoy(ms) {
    const t = moment.utc(ms);
    const days = parseInt(t.format('DDD'))-1;
    const daystr = days > 0 ? `${days}d ` : '';
    return `${daystr}${t.format('H\\h mm:ss.SSS')}`;
  }
});
 });
