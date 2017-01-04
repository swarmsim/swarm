'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'playfab', ->
  template: """
<div ng-include="'views/playfab/title.html'"></div>
<playfabauth ng-if="!isAuthed"></playfabauth>
<playfaboptions ng-if="isAuthed"></playfaboptions>
"""
  restrict: 'EA'
  link: (scope, element, attrs) ->
    scope.isAuthed = false
