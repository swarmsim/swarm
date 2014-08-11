'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, env, session) ->
  $scope.env = env

  $scope.saveState = ->
    session.exportSave()

  $scope.feedbackUrl = ->
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent $scope.saveState()}"
  
  $scope.isNonprod = ->
    $scope.env and $scope.env != 'prod'
