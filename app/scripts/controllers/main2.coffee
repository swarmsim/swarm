'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:Main2Ctrl
 # @description
 # # Main2Ctrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'Main2Ctrl', ($scope, $log, game, $routeParams, $route, version, options) ->
  $scope.game = game
  $scope.options = options
  
  $scope.cur =
    tab: $scope.game.tabs.byName[$routeParams.tab] ? $scope.game.tabs.list[0]
  if not $scope.cur.tab?
    $route.updateParams tab:undefined

  $scope.filterVisible = (unit) -> unit.isVisible()

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.game.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"
