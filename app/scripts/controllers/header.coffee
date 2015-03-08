'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, $window, env, version, session, timecheck, $http, $interval, $log, $location
achievePublicTest1, kongregateScrolling, pageTheme
# analytics/statistics not actually used, just want them to init
versioncheck, analytics, statistics, achievementslistener, favico
) ->
  $scope.env = env
  $scope.version = version
  $scope.session = session

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


  achievePublicTest1 $scope
  kongregateScrolling $scope
  pageTheme $scope

angular.module('swarmApp').factory 'pageTheme', ($log, options) -> return ($scope) ->
  $scope.options = options
  themeEl = options.constructor.THEME_EL
  $scope.$watch 'options.theme()', (theme, oldval) =>
    # based on https://stackoverflow.com/questions/19192747/how-to-dynamically-change-themes-after-clicking-a-drop-down-menu-of-themes
    if theme.url != themeEl.attr 'href'
      themeEl.attr 'href', theme.url
  $scope.$watch 'options.themeExtra()', (css, oldval) =>
    if css?
      if not $scope.themeExtraEl?
        $scope.themeExtraEl = $('<style type="text/css"></style>')
        $scope.themeExtraEl.appendTo 'body'
      $scope.themeExtraEl.html css
      $log.debug 'extratheming', $scope.themeExtraEl, css

angular.module('swarmApp').factory 'kongregateScrolling', ($log, kongregate, options) -> return ($scope) ->
  $scope.options = options
  if !kongregate.isKongregate()
    return
  $scope.$watch 'options.scrolling()', (newval, oldval) =>
    if newval != oldval
      options.isScrollingChangedSincePageLoad = true
      if oldval == 'resize'
        options.isScrollingChangedFromResizeSincePageLoad = true
    kongregate.onScrollOptionChange !options.isScrollingChangedSincePageLoad, oldval
  kongregate.onScrollOptionChange !options.isScrollingChangedSincePageLoad
  $scope.onRender = ->
    kongregate.onResize()

angular.module('swarmApp').factory 'achievePublicTest1', (version, $log, $location, $timeout, game, isKongregate) -> return ($scope) ->
  # use an iframe to ask the publictest server if the player's eligible for the achievement
  framed = window.top and window != window.top
  alreadyEarned = game.achievement('publictest1').isEarned()
  isPublicTest = _.contains version, '-publictest'
  # accidentally pushed this to publictest with isPublicTest broken - seemed to work, though! `framed` stopped any loops.
  # kongregate doesn't like iframes, and newer kongregate players won't qualify anyway
  $scope.loadIframe = (not framed) and (not alreadyEarned) and (not isKongregate()) #and (not isPublicTest)
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

