'use strict'

angular.module('swarmApp').directive 'dropdownMenuAutoDirection', ($compile, $log) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    dropdownMenuClassName = ->
      # https://stackoverflow.com/questions/17095851/check-if-element-is-off-right-edge-of-screen
      rightEdge = $(element).width() + $(element).offset().left
      screenWidth = $(window).width()
      rightLeft = if screenWidth < rightEdge then 'right' else 'left'
      return 'dropdown-menu-'+rightLeft
    attrs.$set 'class', 'dropdown-menu '+dropdownMenuClassName()
