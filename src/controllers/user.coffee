'use strict'

angular.module('swarmApp').factory 'userResource', ($log, $location, $routeParams, userApi, loginApi) -> new class UserResource
  constructor: ->
    # TODO htmlify descriptions
    @leagues =
      list: [{
        name: 'open'
        label: 'Open League'
        isPlayable: true
        desc: 'The default league. Never ends.'
      },{
        name: 'void'
        label: 'Null League (Unplayable)'
        isPlayable: false
        desc: 'This character is no longer playable.'
      },{
        name: 'temp1'
        label: 'Test Temporary League'
        isPlayable: true
        desc: 'x3 larva production or something. I dunno, TBD before the publictest release. Characters join open league after a month or so.'
      }]
    @leagues.byName = _.keyBy @leagues.list, 'name'
    # because I can't get ng-repeat filters working
    @leagues.playableList = _.filter @leagues.list, 'isPlayable'
    
  init: ($scope) ->
    $scope.leagues = @leagues
    $scope._loginApi = loginApi # for watch
    if not ($scope.userSlug=userId=$routeParams.user)?
      $location.url '/'
    do $scope.refreshUser = ->
      # special case: /user/me gets the current user
      if userId == 'me'
        $scope.user = loginApi.user
        $log.debug 'userload hook', $scope.user
        $scope.$watch '_loginApi.user', (user, olduser) =>
          $scope.user = user
          $log.debug 'user loaded', $scope.user
      else
        $scope.user = userApi.get id:userId
    $scope.$watchCollection '[user.id, _loginApi.user]', =>
      $scope.isSelf = $scope.user?.id? and $scope.user.id == loginApi.user?.id

###*
 # @ngdoc function
 # @name swarmApp.controller:UserCtrl
 # @description
 # # UserCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'UserCtrl', ($scope, $log, userResource, $routeParams, characterApi) ->
  $log.debug 'userctrl', $routeParams
  userResource.init $scope

  $scope.$watch 'user.characters', (chars) ->
    $scope.characters = _.map chars, (char) ->
      return _.extend {}, char,
        _raw: char
        league: $scope.leagues.byName[char.league]
        updatedAt: moment char.updatedAt
        createdAt: moment char.createdAt
  $scope.onDelete = (character) ->
    if character.name == window.prompt "Are you sure? Type this character's name to confirm deletion."
      characterApi.update {id:character.id},
        deleted: true
        -> $scope.refreshUser()
  $scope.onDupe = (character) ->
    $log.debug 'duplicating character', character
    characterApi.save _.omit(character._raw, 'id', 'createdAt', 'updatedAt'),
      ->
        $log.debug 'duplicated character', character
        $scope.refreshUser()

angular.module('swarmApp').controller 'NewCharacterCtrl', ($scope, $log, userResource, characterApi, $location) ->
  userResource.init $scope
  $scope.form =
    name: 'Unnamed Swarm'
    league: 'open'

  $scope.onSubmit = ->
    characterApi.save
      name: $scope.form.name
      league: $scope.form.league
      source: 'newCharForm'
      state: {}
      user: $scope.user.id
      (character) ->
        $location.url "/c/#{character.id}"
