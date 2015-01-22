'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, $window, env, version, session, timecheck, $http, $interval, $log, $location
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
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"
    #"https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform"
