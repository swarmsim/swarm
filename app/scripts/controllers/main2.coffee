'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:Main2Ctrl
 # @description
 # # Main2Ctrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'Main2Ctrl', ($scope, $log, util, game, options, $interval, $routeParams, $route, version) ->
  $scope.game = game
  $scope.tabs = $scope.game.tabs
  
  $scope.cur =
    tab: $scope.tabs.byName[$routeParams.tab] ? $scope.tabs.list[0]
  if not $scope.cur.tab?
    $route.updateParams tab:undefined

  $scope.filterVisible = (unit) -> unit.isVisible()

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.game.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"

  util.animateController $scope, game:game, options:options
