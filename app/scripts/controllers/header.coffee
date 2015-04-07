'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, $window, env, version, session, timecheck, $http, $interval, $log, $location
achievePublicTest1, kongregateScrolling, pageTheme, remoteSaveInit, touchTooltipInit
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
  remoteSaveInit $scope
  touchTooltipInit $scope

angular.module('swarmApp').factory 'pageTheme', ($log, options) -> return ($scope) ->
  $scope.options = options
  themeEl = options.constructor.THEME_EL
  $scope.$watch 'options.theme()', (theme, oldval) =>
    # based on https://stackoverflow.com/questions/19192747/how-to-dynamically-change-themes-after-clicking-a-drop-down-menu-of-themes
    if theme.url != themeEl.attr 'href'
      themeEl.attr 'href', theme.url
    body = $('body')
    if oldval?
      body.removeClass "theme-#{oldval.name}"
    body.addClass "theme-#{theme.name}"
  $scope.$watch 'options.themeExtra()', (css, oldval) =>
    if css? or oldval?
      if not $scope.themeExtraEl?
        $scope.themeExtraEl = $('<style type="text/css"></style>')
        $scope.themeExtraEl.appendTo 'body'
      $scope.themeExtraEl.html css
      $log.debug 'extratheming', $scope.themeExtraEl, css

angular.module('swarmApp').factory 'kongregateScrolling', ($log, kongregate, kongregateS3Syncer, options) -> return ($scope) ->
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

angular.module('swarmApp').factory 'remoteSaveInit', ($log, kongregate, kongregateS3Syncer, dropboxSyncer, options) -> return ($scope) ->
  $scope.$watch 'options.autopush()', (newval, oldval) =>
    for syncer in [kongregateS3Syncer, dropboxSyncer] then do (syncer) =>
      $log.debug 'autopush trying to setup', syncer.constructor.name
      if syncer.isVisible()
        $log.debug 'autopush visible', syncer.constructor.name
        if syncer.isInit()
          $log.debug 'autopush setup', syncer.constructor.name
          syncer.initAutopush newval
        else
          $log.debug 'autopush not yet init', syncer.constructor.name
          syncer.init ->
            $log.debug 'autopush init done, checking success', syncer.constructor.name
            if syncer.isInit()
              $log.debug 'autopush setup', syncer.constructor.name
              syncer.initAutopush newval

angular.module('swarmApp').factory 'achievePublicTest1', (version, $log, $location, $timeout, game, isKongregate) -> return ($scope) ->
  # use an iframe to ask the publictest server if the player's eligible for the achievement
  framed = window.top and window != window.top
  alreadyEarned = game.achievement('publictest1').isEarned()
  isPublicTest = _.contains version, '-publictest'
  # accidentally pushed this to publictest with isPublicTest broken - seemed to work, though! `framed` stopped any loops.
  # kongregate doesn't like iframes, and newer kongregate players won't qualify anyway
  #$scope.loadIframe = (not framed) and (not alreadyEarned) and (not isKongregate()) #and (not isPublicTest)
  $scope.loadIframe = false
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

angular.module('swarmApp').factory 'touchTooltipInit', ($log, $location, $timeout) -> return ($scope) ->
  # Show tooltips for touch-devices where the user's actually using touch.
  body = $('body')
  doc = $(window.document)
  setupEvents = 'touchstart touchmove touchend touchcancel'
  #runEvents = 'touchstart touchmove touchend'
  if $location.search().mousetouch
    setupEvents += ' mousedown mouseup'
    #runEvents += ' mousedown mouseup'

  setupTouch = ->
    $log.debug 'touch event detected, setting up tooltip-on-touch'
    doc.off setupEvents, setupTouch
    selector = '[title]'
    body.tooltip
      selector: selector
      trigger: 'click'
      # I give up. Trigger it for clicks too *after* any touch event happens
      #trigger: 'manual'
    #openTooltips = []
    #openTimer = []
    #body.on runEvents, selector, ->
    #  el = $(this)
    #  el.tooltip 'show'
    #  alreadyOpen = false
    #  for open in openTooltips
    #    if open != el
    #      open.tooltip 'hide'
    #    else
    #      alreadyOpen = true
    #  for timer in openTimer
    #    $timeout.cancel timer
    #  if not alreadyOpen
    #    openTooltips.push el
    #  openTimer.push $timeout (-> el.tooltip 'hide'), 5000
  doc.on setupEvents, setupTouch
  $log.debug 'adding setupTouch hook'
  #if document.documentElement.onTouchStart? # IE has this even for non-touchscreens. also fails for touch-and-mouse devices where user isn't actually touching
  #  placement: 'bottom'
  #container: 'body'
  #  animation: false # unfortunate, but the fade + reposition below is awkward
  #.on 'click', selector, (event) ->
  #  console.log 'tooltipclickevent', event, position:'absolute',left:event.clientX, top:event.clientY, $('.tooltip.top')
  #  el = $('.tooltip.top')
  #  el.css left:event.clientX - el.width()/2, top:event.clientY + el.height()
