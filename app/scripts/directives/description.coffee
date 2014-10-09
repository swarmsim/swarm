'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:description
 # @description
 #
 # Use template-compiled unit and upgrade descriptions.
 # http://www.benlesh.com/2013/08/angular-compile-how-it-works-how-to-use.html
 # Actual compilation, with $compile, is done in unit.coffee and upgrade.coffee.
###
angular.module('swarmApp').directive 'unitdesc', (game) ->
  template: ''
  scope:
    unit: '='
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.game ?= game
    # avoid $compile memory leak. #168, http://roubenmeschian.com/rubo/?p=51
    descscope = scope.$new()
    desc = scope.unit.descriptionFn descscope
    element.append desc

    scope.$on '$destroy', ->
      descscope.$destroy()

angular.module('swarmApp').directive 'upgradedesc', (game) ->
  template: ''
  scope:
    upgrade: '='
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.game ?= game
    # avoid $compile memory leak. #168, http://roubenmeschian.com/rubo/?p=51
    descscope = scope.$new()
    desc = scope.upgrade.descriptionFn descscope
    element.append desc

    scope.$on '$destroy', ->
      descscope.$destroy()
