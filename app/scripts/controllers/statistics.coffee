'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:StatisticsCtrl
 # @description
 # # StatisticsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'StatisticsCtrl', ($scope, session, statistics, game) ->
  $scope.listener = statistics
  $scope.session = session
  $scope.stats = session.statistics
  $scope.game = game

  # http://stackoverflow.com/questions/13262621
  utcdoy = (ms) ->
    t = moment.utc(ms)
    "#{parseInt(t.format 'DDD')-1}d #{t.format 'H\\h mm:ss.SSS'}"

  $scope.unitStats = (unit) ->
    ustats = _.clone $scope.stats.byUnit?[unit?.name]
    if ustats?
      ustats.elapsedFirstStr = utcdoy ustats.elapsedFirst
    return ustats
  $scope.hasUnitStats = (unit) -> !!$scope.unitStats unit

  $scope.upgradeStats = (upgrade) ->
    ustats = $scope.stats.byUpgrade[upgrade.name]
    if ustats?
      ustats.elapsedFirstStr = utcdoy ustats.elapsedFirst
    return ustats
  $scope.hasUpgradeStats = (upgrade) -> !!$scope.upgradeStats upgrade
