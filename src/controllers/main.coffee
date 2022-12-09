'use strict'
# import _ from 'lodash'

###*
 # @ngdoc function
 # @name swarmApp.controller:Main2Ctrl
 # @description
 # # Main2Ctrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'MainCtrl', ($scope, $log, game, $routeParams, $location, version, options, hotkeys) ->
  $scope.game = game
  $scope.options = options

  # special case: buy-energy links redirect to crystals
  if $routeParams.unit == 'energy' and $routeParams.tab == 'energy' and $location.search().num?
    # console.log 'hellohello', $location.search().num
    $location.path '/tab/energy/unit/crystal'
  
  $scope.cur = {}
  $scope.cur.unit = $scope.game.unitBySlug $routeParams.unit
  $scope.cur.tab = $scope.game.tabs.byName[$routeParams.tab] ? $scope.cur.unit?.tab ? $scope.game.tabs.list[0]
  $scope.cur.tab.lastselected = $scope.cur.unit
  # if it's a bogus tab name, or the tab's not visible (ex. energy before first nexus)
  if ($routeParams.tab != $scope.cur.tab.name and $routeParams.tab?) or not $scope.cur.tab.isVisible()
    $location.url '/'
  # if they asked for a unit but that unit has issues, redirect to no-unit
  if $routeParams.unit? and (
    not $scope.cur.unit? or
    # they gave a bogus unit as a url parameter
    $scope.cur.unit.unittype.slug != $routeParams.unit or
    # they gave a unit that's not in this tab. comparing to unit.tab breaks /tab/all
    not $scope.cur.tab.indexByUnitName[$scope.cur.unit.name]? or
    # the unit they asked for isn't visible yet
    not $scope.cur.unit.isVisible()
  )

    $log.debug 'invalid unit', $routeParams.unit, $scope.cur.unit, (not $scope.cur.unit?), $scope.cur.unit?.unittype?.slug != $routeParams.unit, not $scope.cur.tab.indexByUnitName[$scope.cur.unit?.name]?, not $scope.cur.unit?.isVisible?()
    $location.url $scope.cur.tab.url false
  $log.debug 'tab', $scope.cur

  $scope.click = (unit) ->
    $location.url $scope.cur.tab.url unit

  $scope.filterVisible = (unit) -> unit.isVisible()

  findtab = (index, step) ->
    index += step + game.tabs.list.length
    index %= game.tabs.list.length
    tab = game.tabs.list[index]
    if tab == $scope.cur.tab
      return null
    if tab.isVisible()
      return tab
    return findtab index, step

  hk = hotkeys.bindTo($scope)
  keys = '1234567890'
  # shift+<n> for 11-20
  keys = keys.split('').concat(keys.split('').map((k) -> 'shift+'+k))
  for unit, i in _.reverse(_.filter($scope.cur.tab.sortUnits(), $scope.filterVisible))
    do (unit, i) ->
      if keys[i]?
        hk.add
          combo: keys[i]
          # clutters the screen
          #description: 'Select '+unit.type.plural
          callback: () ->
            $location.path '/unit/'+unit.type.slug
