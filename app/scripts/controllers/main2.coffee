'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:Main2Ctrl
 # @description
 # # Main2Ctrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'Main2Ctrl', ($scope, util, game, options, $interval, $routeParams, $route, version) ->
  util.gateLocation 'main2Enabled'
  $scope.game = game
  $scope.version = version
  console.log 'params', $routeParams

  mktab = (tab) ->
    tab.unit = $scope.game.unit tab.name
    return tab
  $scope.tabs =
    list: (mktab(tab) for tab in [
      {name:'meat', groups:[1]}
      {name:'larva', groups:[]}
      {name:'territory', groups:[2]}])
  $scope.tabs.byName = _.indexBy $scope.tabs.list, 'name'
  $scope.units =
    byLabel: _.indexBy $scope.game.unitlist(), (u) -> u.unittype.label
  $scope.units.byGroup = {}
  for unit in $scope.game.unitlist()
    grouplist = $scope.units.byGroup[unit.unittype.column] ?= []
    grouplist.push unit
  
  $scope.cur =
    tab: $scope.tabs.byName[$routeParams.tab or 'meat']
    unit: $scope.units.byLabel[$routeParams.unit]
  if not $scope.cur.tab?
    $route.updateParams tab:undefined, unit:undefined
  #if not $scope.cur.unit? and $routeParams.unit
  #  $route.updateParams unit:undefined

  animatePromise = $interval (=>$scope.game.tick()), options.fpsSleepMillis()
  $scope.$on '$destroy', =>
    $interval.cancel animatePromise

  # filter
  $scope.isVisible = (group) ->
    (unit) ->
      unit.unittype.column == group and unit.isVisible()

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.game.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"
