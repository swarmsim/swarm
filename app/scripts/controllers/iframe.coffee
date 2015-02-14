'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:IframeCtrl
 # @description
 # # IframeCtrl
 #
 # Call another swarmsim server via iframe
###
angular.module('swarmApp').controller 'IframeCtrl', ($scope, $log, $routeParams, game, version) ->
  $scope.framed = window.top and window != window.top
  $scope.call = $routeParams.call

  if $scope.call == 'achieve-publictest1'
    count = new Decimal 0
    # Check the count for multiple savestate slots - want to credit people for all publictest resets.
    # Ascensions have no velocity, so we can just check the savestate json directly.
    savestateKeys = [game.session.id, 'v0.2']
    for key in savestateKeys
      if (encoded = localStorage.getItem key)?
        try
          state = game.session._loads encoded
          statecount = state.unittypes.ascension
          $log.debug "iframe controller: ascension count for savestate with key '#{key}' is #{statecount}"
          if statecount
            count = Decimal.max count, statecount
        catch e
          # invalid save, ignore it
          $log.debug "iframe controller: error loading savestate #{key} while checking publictest achievement. ignoring.", e
    response =
      achieved: count.greaterThan(0)
      ascensions: count
      date: new Date()

  $scope.response = response
  $log.info 'iframe controller:', framed:$scope.framed, call:$scope.call, response:$scope.response
  if $scope.framed
    window.top.postMessage JSON.stringify(response), '*'
