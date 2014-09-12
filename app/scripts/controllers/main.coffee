'use strict'

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
  
  $scope.cur =
    tab: $scope.game.tabs.byName[$routeParams.tab] ? $scope.game.tabs.list[0]
  if $routeParams.tab != $scope.cur.tab.name
    $location.url '/'

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
  binds = hotkeys.bindTo $scope
  binds.add
    combo: 'left'
    description: 'Go to previous tab'
    callback: ->
      if tab = findtab $scope.cur.tab.index, -1
        $location.url "/tab/#{tab.name}"
  binds.add
    combo: 'right'
    description: 'Go to next tab'
    callback: ->
      if tab = findtab $scope.cur.tab.index, +1
        $location.url "/tab/#{tab.name}"
