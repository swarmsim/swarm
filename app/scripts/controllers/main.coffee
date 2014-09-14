'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:Main2Ctrl
 # @description
 # # Main2Ctrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, $log, game, $routeParams, $location, version, options) ->
  $scope.game = game
  $scope.options = options
  
  $scope.cur =
    tab: $scope.game.tabs.byName[$routeParams.tab] ? $scope.game.tabs.list[0]
  $scope.cur.unit = $scope.game.unitByLabel $routeParams.unit
  if $routeParams.tab != $scope.cur.tab.name and $routeParams.tab?
    $location.url '/'
  # if they asked for a unit but that unit has issues, redirect to no-unit
  if $routeParams.unit? and (
      not $scope.cur.unit? or
      # they gave a bogus unit as a url parameter
      $scope.cur.unit.unittype.label != $routeParams.unit or
      # they gave a unit that's not in this tab. comparing to unit.tab breaks /tab/all
      not $scope.cur.tab.indexByUnitName[$scope.cur.unit.name]? or
      # the unit they asked for isn't visible yet
      not $scope.cur.unit.isVisible())
    $log.debug 'invalid unit', $routeParams.unit, $scope.cur.unit, (not $scope.cur.unit?), $scope.cur.unit.unittype.label != $routeParams.unit, not $scope.cur.tab.indexByUnitName[$scope.cur.unit.name]?, not $scope.cur.unit.isVisible()
    $location.url "/tab/#{$scope.cur.tab.name}"
  $log.debug 'tab', $scope.cur

  $scope.filterVisible = (unit) -> unit.isVisible()

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.game.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"

  findtab = (index, step) ->
    index += step + game.tabs.list.length
    index %= game.tabs.list.length
    tab = game.tabs.list[index]
    if tab == $scope.cur.tab
      return null
    if tab.isVisible()
      return tab
    return findtab index, step
  # No keyboard shortcuts for now. TODO: make more, decent keyboard shortcuts; game should be playable without mouse.
  #binds = hotkeys.bindTo $scope
  #binds.add
  #  combo: 'left'
  #  description: 'Go to previous tab'
  #  callback: ->
  #    if tab = findtab $scope.cur.tab.index, -1
  #      $location.url "/tab/#{tab.name}"
  #binds.add
  #  combo: 'right'
  #  description: 'Go to next tab'
  #  callback: ->
  #    if tab = findtab $scope.cur.tab.index, +1
  #      $location.url "/tab/#{tab.name}"
