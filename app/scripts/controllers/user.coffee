'use strict'

angular.module('swarmApp').factory 'userResource', ($log, $location, $routeParams, userApi, loginApi) -> new class UserResource
  init: ($scope) ->
    if not ($scope.userSlug=userId=$routeParams.user)?
      $location.url '/'
    # special case: /user/me gets the current user
    if userId == 'me'
      $scope.user = loginApi.user
      $log.debug 'userload hook', $scope.user
      $scope._loginApi = loginApi
      $scope.$watch '_loginApi.user', (user, olduser) =>
        $scope.user = user
        $log.debug 'user loaded', $scope.user
      $scope.isSelf = true
    else
      $scope.user = userApi.get id:userId
    

###*
 # @ngdoc function
 # @name swarmApp.controller:UserCtrl
 # @description
 # # UserCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UserCtrl', ($scope, $log, userResource, $routeParams) ->
  $log.debug 'userctrl', $routeParams
  userResource.init $scope

angular.module('swarmApp').controller 'NewCharacterCtrl', ($scope, $log, userResource, characterApi, $location) ->
  userResource.init $scope
  $scope.form =
    name: 'Unnamed Swarm'
    league: 'open'
  # TODO htmlify descriptions
  $scope.leagues =
    list: [{
      name: 'open'
      label: 'Open League'
      desc: 'The default league. Never ends.'
    },{
      name: 'temp1'
      label: 'Test Temporary League'
      desc: 'x3 larva production or something. I dunno, TBD before the publictest release. Characters join open league after a month or so.'
    }]

  $scope.onSubmit = ->
    characterApi.save
      name: $scope.form.name
      league: $scope.form.league
      source: 'newCharForm'
      state: {}
      user: $scope.user.id
      (character) ->
        $location.url "/c/#{character.id}"
