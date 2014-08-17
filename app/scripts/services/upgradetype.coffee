'use strict'

angular.module('swarmApp').factory 'UpgradeType', -> class UpgradeType
  constructor: (data) ->
    _.extend this, data

  totalCost: (level) ->
    return _.map @cost, (cost) ->
      unittype: cost.unittype


angular.module('swarmApp').factory 'UpgradeTypes', (spreadsheetUtil, UpgradeType) -> class UpgradeTypes
  constructor: (@unittypes, upgrades=[]) ->
    @list = []
    @byName = {}
    for upgrade in upgrades
      @register upgrade

  register: (upgrade) ->
    console.log 'register upgrade', upgrade.name, upgrade
    console.assert upgrade.name
    @list.push upgrade
    @byName[upgrade.name] = upgrade

  @parseSpreadsheet: (unittypes, data) ->
    rows = spreadsheetUtil.parseRows {name:['requires','cost','option']}, data.data.upgrades.elements
    ret = new UpgradeTypes unittypes, (new UpgradeType(row) for row in rows when row.name)
    for upgrade in ret.list
      spreadsheetUtil.resolveList upgrade.cost, 'unittype', unittypes.byName
      spreadsheetUtil.resolveList upgrade.requires, 'unittype', unittypes.byName
    return ret

###*
 # @ngdoc service
 # @name swarmApp.upgrade
 # @description
 # # upgrade
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'upgradetypes', (UpgradeTypes, unittypes, spreadsheet) ->
  return UpgradeTypes.parseSpreadsheet unittypes, spreadsheet
