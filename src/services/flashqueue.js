/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc service
 * @name swarmApp.flashqueue
 * @description
 * # flashqueue
 * Factory in the swarmApp.
 *
 * Achievement UI notification and animation.
*/
angular.module('swarmApp').factory('FlashQueue', function($log, $timeout, util) { let FlashQueue;
return (FlashQueue = class FlashQueue {
  constructor(showTime, fadeTime) {
    if (showTime == null) { showTime = 5000; }
    this.showTime = showTime;
    if (fadeTime == null) { fadeTime = 1000; }
    this.fadeTime = fadeTime;
    this.queue = [];
    this._state = 'invisible';
    this._timeout = null;
  }
  push(message) {
    this.queue.push(message);
    return this.animate(); //animate will ignore this if there's other items ahead of us
  }
  animate() {
    if ((this._state === 'invisible') && (this.queue.length > 0)) {
      $log.debug('flashqueue beginning animation', this.get());
      this._state = 'visible';
      return this._timeout = $timeout((() => {
        this._state = 'fading';
        return this._timeout = $timeout((() => {
          $log.debug('flashqueue ending animation', this.get());
          this._state = 'invisible';
          this.queue.shift();
          return this.animate();
        }
        ), this.fadeTime);
      }
      ), this.showTime);
    }
  }
  isVisible() {
    return this._state === 'visible';
  }
  get() {
    return this.queue[0];
  }
  clear() {
    $log.debug('flashqueue clearing animation');
    this.queue.length = 0;
    if (this._timeout) {
      $timeout.cancel(this._timeout);
    }
    return this._state = 'invisible';
  }
});
 });

angular.module('swarmApp').factory('flashqueue', function($log, FlashQueue, $rootScope) {
  const queue = new FlashQueue();

  // TODO this really shouldn't be attached ot the main flashqueue...
  $rootScope.$on('achieve', function(event, achievement) {
    $log.debug('achievement flashqueue pushing achievement', achievement);
    return queue.push(achievement);
  });

  return queue;
});
