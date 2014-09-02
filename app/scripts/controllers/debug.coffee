'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:DebugCtrl
 # @description
 # # DebugCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DebugCtrl', ($scope, session, game, spreadsheet, env, unittypes, $timeout, util) ->
  console.log 'debugs', game, unittypes
  $scope.dumps = [
    {title:'env', data:env}
    {title:'game', data:!!game}
    {title:'session', data:session}
    {title:'unittypes', data:!!unittypes}
    {title:'spreadsheet', data:spreadsheet}
    ]

  $scope.notify = new class Notify
    constructor: (@showTime=5000, @fadeTime=1000) ->
      @queue = []
      @_state = 'invisible'
      @_timeout = null
    push: (message) ->
      @queue.push message
      if @queue.length == 1 #just pushed the only item
        @animate()
    animate: ->
      if @_state == 'invisible'
        @_state = 'visible'
        @_timeout = $timeout (=>
          @_state = 'fading'
          @_timeout = $timeout (=>
            @_state = 'invisible'
            @queue.shift()
            if @queue.length
              @animate()
          ), @fadeTime
        ), @showTime
    isVisible: ->
      @_state == 'visible'
    get: ->
      @queue[0]
  $timeout (->$scope.notify.push {label:'hihi', points:10, description:'ahaha'}), 1000

  $scope.throwUp = ->
    throw new Error "throwing up (test exception)"
  $scope.form = {}
  $scope.session = session
  $scope.$watch 'form.session', (text, text0) ->
    if text != text0
      console.log 'formsession update', text, $scope.session._saves text, false
      $scope.session.importSave $scope.session._saves JSON.parse(text), false
    else
      console.log 'formsession equal'
  $scope.$watch 'session', do ->
    console.log 'session update'
    $scope.form.sessionExport = $scope.session.exportSave()
    $scope.form.session = JSON.stringify $scope.session._loads($scope.form.sessionExport), undefined, 2
  $scope.game = game
  $scope.env = env
  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. You sure?'
      game.reset()
