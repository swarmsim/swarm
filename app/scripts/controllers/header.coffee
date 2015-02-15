'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, $window, env, version, session, timecheck, $http, $interval, $log, $location, achievePublicTest1, linkPublicTest1
# analytics/statistics not actually used, just want them to init
versioncheck, analytics, statistics, achievementslistener, favico, kongregate
) ->
  $scope.env = env
  $scope.version = version
  $scope.session = session

  themes = {'dark-ff':true,'dark-chrome':true}
  if theme = $location.search().theme
    if themes[theme]
      $log.debug 'themeing', theme
      $('html').addClass "theme-#{theme}"
    else
      $log.warn 'invalid theme, ignoring', theme

  do enforce = ->
    timecheck.enforceNetTime().then(
      (invalid) ->
        $log.debug 'net time check successful', invalid
        $scope.netTimeInvalid = invalid
        if invalid
          $log.debug 'cheater', invalid
          # Replacing ng-view (via .viewwrap) disables navigation to other pages.
          # This is hideous technique and you, reader, should not copy it.
          $('.viewwrap').before '<div><p class="cheater">There is a problem with your system clock.</p><p>If you don\'t know why you\'re seeing this, <a target="_blank" href=\"http://www.reddit.com/r/swarmsim\">ask about it here</a>.</p></div>'
          $('.viewwrap').css({display:'none'})
          $('.footer').css({display:'none'})
          $interval.cancel enforceInterval
      ->
        $log.warn 'failed to check net time'
      )
  enforceInterval = $interval enforce, 1000 * 60 * 30

  $scope.konami = new Konami ->
    $scope.$emit 'konami'
    $log.debug 'konami'

  $scope.feedbackUrl = ->
    session.feedbackUrl()

  achievePublicTest1 $scope
  try
    linkPublicTest1 $scope
  catch e
    # pass

angular.module('swarmApp').factory 'achievePublicTest1', (version, $log, $location, $timeout, game, kongregate) -> return ($scope) ->
  # use an iframe to ask the publictest server if the player's eligible for the achievement
  framed = window.top and window != window.top
  alreadyEarned = game.achievement('publictest1').isEarned()
  isPublicTest = _.contains version, '-publictest'
  # accidentally pushed this to publictest with isPublicTest broken - seemed to work, though! `framed` stopped any loops.
  # kongregate doesn't like iframes, and newer kongregate players won't qualify anyway
  $scope.loadIframe = (not framed) and (not alreadyEarned) and (not kongregate.isKongregate()) #and (not isPublicTest)
  $log.debug 'achievePublicTest1: creating iframe:', $scope.loadIframe, framed:framed, alreadyEarned:alreadyEarned, isPublicTest:isPublicTest
  if $scope.loadIframe
    # setup a message-handler; cleanup either when the message arrives, or after 30 seconds
    cleanup = ->
      onmessage.off()
      $timeout.cancel timeout
      $scope.loadIframe = false
    onmessage = $(window).on 'message', (e) ->
      try
        data = e?.originalEvent?.data
        data = JSON.parse data
        $log.debug 'achievePublicTest1: iframe response', e, data, data.achieved
        if data.achieved
          $scope.$emit 'achieve-publictest1'
      finally
        cleanup()
    timeout = $timeout cleanup, 30000

angular.module('swarmApp').factory 'linkPublicTest1', ($log, $location, game, kongregate) -> return ($scope) ->
  encoded = $location.search().publictest
  if encoded
    args = JSON.parse LZString.decompressFromBase64 encoded
    datediff = Math.abs new Date().getTime() - new Date(args.date ? 0).getTime()
    if datediff < 5 * 60 * 1000
      $scope.$emit 'achieve-publictest1'
      $log.debug 'linkPublicTest1: achieve-publictest1', datediff
      $location.search 'publictest', null
