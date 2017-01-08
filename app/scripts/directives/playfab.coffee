'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'playfab', (playfab, wwwPlayfabSyncer) ->
  template: """
<div ng-if="isVisible()">
  <div ng-include="'views/playfab/title.html'"></div>
  <playfabauth ng-if="!isAuthed()"></playfabauth>
  <playfaboptions ng-if="isAuthed()"></playfaboptions>
</div>
"""
  restrict: 'EA'
  link: (scope, element, attrs) ->
    scope.isVisible = -> wwwPlayfabSyncer.isVisible()
    scope.isAuthed = -> playfab.isAuthed()
