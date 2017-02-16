'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:description
 # @description
 #
 # Use either static descriptions from the spreadsheet, or templated descriptions in /app/views/desc.
 # Spreadsheet descriptions of '' or '-' indicate that we should try to use a template.
 # (We used to do stupid $compile tricks to allow templating in the spreadsheet, but that caused memory leaks. #177)
###
angular.module('swarmApp').directive 'unitdesc', (game, commands, options) ->
  template: '<p ng-if="templateUrl" ng-include="templateUrl" class="desc desc-unit desc-template desc-{{unit.name}}"></p><p ng-if="!templateUrl" class="desc desc-unit desc-text desc-{{unit.name}}">{{desc}}</p>'
  scope:
    unit: '='
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.game ?= game
    scope.commands = commands
    scope.options = options
    scope.desc = scope.unit.unittype.description
    scope.templateUrl = do ->
      if scope.desc == '-' or not scope.desc
        return "views/desc/unit/#{scope.unit.name}.html"
      return ''

angular.module('swarmApp').controller 'MtxDesc', ($scope, mtx, commands) ->
  $scope.mtx = mtx
  $scope.mtx.pull().then(
    () ->
      $scope.pullError = null
    (error) ->
      $scope.pullError = error
  )
  $scope.mtx.packs().then(
    (mtxPacks) ->
      $scope.packs = mtxPacks
      $scope.packsError = null
    (error) ->
      $scope.packs = null
      $scope.packsError = error
  )
  $scope.clickBuyPack = (pack) ->
    $scope.buyMessage = null
    $scope.mtx.buy(pack.name).then(
      (res) ->
        $scope.buyMessage = "Thank you for supporting Swarm Simulator!"
      (error) ->
        $scope.buyMessage = "Thanks for looking!"
    )
  $scope.clickConvert = (conversion) ->
    $scope.convertError = null
    try
      commands.convertCrystal({conversion: conversion})
    catch e
      $scope.convertError = e

angular.module('swarmApp').directive 'upgradedesc', (game, commands, options) ->
  template: '<p ng-if="templateUrl" ng-include="templateUrl" desc desc-upgrade desc-template desc-{{upgrade.name}}"></p><p ng-if="!templateUrl" class="desc desc-upgrade desc-text desc-{{upgrade.name}}">{{desc}}</p>'
  scope:
    upgrade: '='
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.game ?= game
    scope.commands = commands
    scope.options = options
    scope.desc = scope.upgrade.type.description
    scope.templateUrl = do ->
      if scope.desc == '-' or not scope.desc
        return "views/desc/upgrade/#{scope.upgrade.name}.html"
      return ''
