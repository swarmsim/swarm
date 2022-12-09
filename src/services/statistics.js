/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import {Decimal} from 'decimal.js';

/**
 * @ngdoc service
 * @name swarmApp.statistics
 * @description
 * # statistics
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('StatisticsListener', function(util, $log, kongregate) { let StatisticsListener;
return StatisticsListener = class StatisticsListener {
  constructor(session, scope) {
    this.session = session;
    this.scope = scope;
    this._init();
  }

  _init() {
    const stats = this.session.state.statistics != null ? this.session.state.statistics : (this.session.state.statistics = {});
    if (stats.byUnit == null) { stats.byUnit = {}; }
    if (stats.byUpgrade == null) { stats.byUpgrade = {}; }
    return stats.clicks != null ? stats.clicks : (stats.clicks = 0);
  }
  
  push(cmd) {
    let e, ustats;
    const stats = this.session.state.statistics;
    stats.clicks += 1;
    if (cmd.unitname != null) {
      ustats = stats.byUnit[cmd.unitname];
      if ((ustats == null)) {
        ustats = (stats.byUnit[cmd.unitname] = {clicks:0,num:0,twinnum:0,elapsedFirst:cmd.elapsed});
        this.scope.$emit('buyFirst', cmd);
      }
      ustats.clicks += 1;
      try {
        ustats.num = new Decimal(ustats.num).plus(cmd.num);
        ustats.twinnum = new Decimal(ustats.twinnum).plus(cmd.twinnum);
      } catch (error) {
        e = error;
        $log.warn('statistics corrupt for unit, resetting', cmd.unitname, ustats, e);
        ustats.num = new Decimal(cmd.num);
        ustats.twinnum = new Decimal(cmd.twinnum);
      }
    }
    if (cmd.upgradename != null) {
      ustats = stats.byUpgrade[cmd.upgradename];
      if ((ustats == null)) {
        ustats = (stats.byUpgrade[cmd.upgradename] = {clicks:0,num:0,elapsedFirst:cmd.elapsed});
        this.scope.$emit('buyFirst', cmd);
      }
      ustats.clicks += 1;
      try {
        ustats.num = new Decimal(ustats.num).plus(cmd.num);
      } catch (error1) {
        e = error1;
        $log.warn('statistics corrupt for upgrade, resetting', cmd.upgradename, ustats, e);
        ustats.num = new Decimal(cmd.num);
      }
    }
    this.session.save(); //TODO session is saved twice for every command, kind of lame
    delete cmd.now;
    delete cmd.unit;
    return delete cmd.upgrade;
  }

  listen(scope) {
    scope.$on('reset', () => {
      return this._init();
    });
    return scope.$on('command', (event, cmd) => {
      $log.debug('statistics', event, cmd);
      this.push(cmd);
      return kongregate.reportStats();
    });
  }
};
 });

angular.module('swarmApp').factory('statistics', function(session, StatisticsListener, $rootScope) {
  const stats = new StatisticsListener(session, $rootScope);
  stats.listen($rootScope);
  return stats;
});
