/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc service
 * @name swarmApp.favico
 * @description
 * # favico
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('favico', function(game, env, $rootScope, $log) {
  let ret;
  if (window.Favico != null) {
    let FavicoService;
    ret = new (FavicoService = class FavicoService {
      constructor() {
        this.instance = new Favico({
          animation: 'none'});
        this.lastcount = 0;
      }
      update() {
        const units = game.getNewlyUpgradableUnits();
        const count = units.length;
        if (count !== this.lastcount) {
          $log.debug('favicon update', {stale:this.lastcount, fresh:count, units});
          if (count > 0) {
            this.instance.badge(count);
          } else {
            this.instance.reset();
          }
        }
        return this.lastcount = count;
      }
    });
  } else {
    // unit tests refuse to load favico for some reason
    let UnitTestFavicoService;
    ret = new (UnitTestFavicoService = class UnitTestFavicoService {
      constructor() {}
      update() {}
    });
  }
  $rootScope.$on('tick', () => ret.update());
  return ret;
});
