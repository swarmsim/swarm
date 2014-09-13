'use strict'

angular.module('swarmApp').factory 'Tab', -> class Tab
  constructor: (@leadunit, @index, @name = @leadunit.name) ->
    @units = []
    @allunits = [@leadunit]
    @sortedUnits = []
    @sortedAllUnits = [@leadunit]
    @indexByUnitName = {}

  push: (unit) ->
    @indexByUnitName[unit.name] = @units.length
    @units.push unit
    @allunits.push unit
    # usually this is reverse order, highest tier first
    @sortedUnits.unshift unit
    @sortedAllUnits.unshift unit

  # TODO rename nextunit, prevunit
  next: (unit) ->
    index = @indexByUnitName[unit?.name ? unit]
    return @units[index + 1]
  prev: (unit) ->
    index = @indexByUnitName[unit?.name ? unit]
    return @units[index - 1]

  isVisible: ->
    @leadunit.isVisible()

  isNewlyUpgradable: ->
    _.some @allunits, (unit) ->
      unit.isVisible() and unit.isNewlyUpgradable()

  @buildTabs: (unitlist) ->
    ret =
      list: []
      byName: {}
      byUnit: {}
    # a magic tab with all the units. Deliberately not listed/displayed.
    all = null

    for unit in unitlist
      if unit.unittype.tab and not unit.unittype.disabled
        tab = ret.byName[unit.unittype.tab]
        if tab?
          tab.push unit
        else
          # tab leader comes first in the spreadsheet
          tab = ret.byName[unit.unittype.tab] = new Tab unit, ret.list.length
          ret.list.push tab
        ret.byUnit[unit.name] = tab
        if not all
          all = ret.byName.all = new Tab unit, 1, 'all'
        else
          all.push unit
    # the magic 'all' tab is the exception, don't reverse its units
    all.sortedUnits.reverse()
    all.sortedAllUnits.reverse()
    return ret

