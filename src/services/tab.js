/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';

angular.module('swarmApp').factory('Tab', function() { let Tab;
return Tab = class Tab {
  constructor(leadunit, index, name) {
    this.leadunit = leadunit;
    this.index = index;
    this.name = name;
    this.units = [];
    this.sortedUnits = [];
    this.indexByUnitName = {};
    this.push(this.leadunit);
  }

  push(unit) {
    this.indexByUnitName[unit.name] = this.units.length;
    this.units.push(unit);
    // usually this is reverse order, highest tier first
    return this.sortedUnits.unshift(unit);
  }

  // TODO rename nextunit, prevunit
  next(unit) {
    const index = this.indexByUnitName[(unit != null ? unit.name : undefined) != null ? (unit != null ? unit.name : undefined) : unit];
    return this.units[index + 1];
  }
  prev(unit) {
    const index = this.indexByUnitName[(unit != null ? unit.name : undefined) != null ? (unit != null ? unit.name : undefined) : unit];
    return this.units[index - 1];
  }

  isVisible() {
    return this.leadunit.isVisible();
  }

  isNewlyUpgradable() {
    return _.some(this.units, unit => unit.isVisible() && unit.isNewlyUpgradable());
  }

  sortUnits() {
    if (this.name === 'all') {
      return this.sortedUnits;
    }
    return _.sortBy(this.sortedUnits, u => // default ascending, hack for descending sort
    -1 * u.stat('empower', 0));
  }

  static buildTabs(unitlist) {
    const ret = {
      list: [],
      byName: {},
      byUnit: {}
    };
    // a magic tab with all the units. Deliberately not listed/displayed.
    let all = null;

    for (var unit of Array.from(unitlist)) {
      if (unit.unittype.tab && !unit.unittype.disabled) {
        var tab = ret.byName[unit.unittype.tab];
        if (tab != null) {
          tab.push(unit);
        } else {
          // tab leader comes first in the spreadsheet
          tab = (ret.byName[unit.unittype.tab] = new Tab(unit, ret.list.length, unit.name));
          ret.list.push(tab);
        }
        ret.byUnit[unit.name] = tab;
        if (!all) {
          all = (ret.byName.all = new Tab(unit, 1, 'all'));
        } else {
          all.push(unit);
        }
      }
    }
    // the magic 'all' tab is the exception, don't reverse its units
    all.sortedUnits.reverse();
    return ret;
  }

  // TODO should probably centralize url building in its own factory, instead of a method
  // @lastselected set by /controllers/main.coffee
  url(unit) {
    if (unit == null) { unit = this.lastselected; }
    const unitsuffix = unit ? `/unit/${unit.unittype.slug}` : "";
    return `/tab/${this.name}${unitsuffix}`;
  }
};
 });

