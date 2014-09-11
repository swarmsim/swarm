'use strict'

angular.module('swarmApp').factory 'Tab', -> class Tab
  constructor: (@leadunit) ->
    @units = []
    @indexByUnitName = {}
    @name = @leadunit.name

  push: (unit) ->
    @indexByUnitName[unit.name] = @units.length
    @units.push unit

  next: (unit) ->
    index = @indexByUnitName[unit?.name ? unit]
    return @units[index + 1]
  prev: (unit) ->
    index = @indexByUnitName[unit?.name ? unit]
    return @units[index - 1]

  isVisible: ->
    @leadunit.isVisible()

  @buildTabs: (unitlist) ->
    ret =
      list: []
      byName: {}
      byUnit: {}
    for unit in unitlist
      if unit.unittype.tab and not unit.unittype.disabled
        tab = ret.byName[unit.unittype.tab]
        if tab?
          tab.push unit
        else
          # tab leader comes first in the spreadsheet
          tab = ret.byName[unit.unittype.tab] = new Tab unit
          ret.list.push tab
        ret.byUnit[unit.name] = tab
    return ret

