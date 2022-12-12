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

angular.module('swarmApp').controller 'MtxDesc', ($scope, $log, mtx, commands, $location) ->
  $scope.mtx = mtx

  pull = ->
    $scope.pullLoading = true
    $scope.mtx.pull()
    .then ->
      $scope.pullLoading = false
      $scope.pullSuccess = true
      $scope.pullTx = $location.search().tx
      $scope.pullError = null
    .catch (error) ->
      $scope.pullLoading = false
      $scope.pullSuccess = false
      $scope.pullTx = $location.search().tx
      $scope.pullError = error

  $scope.mtx.packs()
  .then (mtxPacks) ->
    $scope.packs = mtxPacks
    $scope.packsError = null
    pull()
  .catch (error) ->
    $scope.packs = null
    $scope.packsError = error
    # don't even bother trying to pull purchases if buy-buttons failed

  $scope.buyLoading = false
  $scope.clickBuyPack = (pack) ->
    $scope.buySuccess = $scope.buyError = null
    $scope.buyLoading = true
    $scope.mtx.buy(pack.name)
    .then (res) ->
      $scope.buySuccess = true
      $scope.buyError = null
      $scope.buyLoading = false
    .catch (error) ->
      $log.error 'buyerror', error
      $scope.buySuccess = false
      $scope.buyError = error
      $scope.buyLoading = false

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
