'use strict'

angular.module('swarmApp').factory 'Tab', -> class Tab
  constructor: (@leadunit) ->
    @units = []
    @indexByUnitName = {}
    @push @leadunit
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
    return ret

###*
 # @ngdoc function
 # @name swarmApp.controller:Main2Ctrl
 # @description
 # # Main2Ctrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'Main2Ctrl', ($scope, $log, util, game, options, $interval, $routeParams, $route, version, Tab) ->
  $scope.game = game
  $log.debug 'params', $routeParams

  $scope.units =
    byLabel: _.indexBy $scope.game.unitlist(), (u) -> u.unittype.label
  $scope.tabs = Tab.buildTabs $scope.game.unitlist()
  
  $scope.cur =
    tab: $scope.tabs.byName[$routeParams.tab] ? $scope.tabs.list[0]
    unit: $scope.units.byLabel[$routeParams.unit]
    next: -> $scope.cur.tab.next $scope.cur.unit
    prev: -> $scope.cur.tab.prev $scope.cur.unit
  if not $scope.cur.tab?
    $route.updateParams tab:undefined, unit:undefined
  if not $scope.cur.unit? and $routeParams.unit
    $route.updateParams unit:undefined
  if $scope.cur.unit? and $scope.cur.tab isnt $scope.tabs.byName[$scope.cur.unit.unittype.tab]
    $route.updateParams unit:undefined

  animatePromise = $interval (=>$scope.game.tick()), options.fpsSleepMillis()
  $scope.$on '$destroy', =>
    $interval.cancel animatePromise

  $scope.filterVisible = (unit) -> unit.isVisible()

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.game.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"
