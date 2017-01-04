'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module 'swarmApp'
  .directive 'playfab-title', ->
    templateUrl: 'views/playfab/title.html'
    restrict: 'EA'
    link: (scope, element, attrs) ->
