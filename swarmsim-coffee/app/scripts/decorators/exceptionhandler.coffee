'use strict'

###*
 # @ngdoc function
 # @name swarmApp.decorator:Exceptionhandler
 # @description
 # # Exceptionhandler
 # Decorator of the swarmApp
###
angular.module("swarmApp").config ($provide) ->
  # in most places minification can figure out what's going on without
  # argnames-as-list, but not here. Fails in dist-build without them.
  $provide.decorator "$exceptionHandler", ['$delegate', '$injector', ($delegate, $injector) ->
    $rootScope = null
    (exception, cause) ->
      $delegate exception, cause
      $rootScope ?= $injector.get '$rootScope' #avoid circular dependency error
      $rootScope.$emit 'unhandledException', {exception:exception, cause:cause}
  ]
