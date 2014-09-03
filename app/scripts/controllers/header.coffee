'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, $window, env, version, session, analytics, statistics, timecheck, versioncheck, $http, $interval) ->
  # analytics/statistics not actually used, just want it to init
  $scope.env = env
  $scope.version = version
  $scope.session = session

  do enforce = ->
    timecheck.enforceNetTime().then(
      (invalid) ->
        #console.log 'net time check successful', invalid
        $scope.netTimeInvalid = invalid
        if invalid
          console.error 'cheater', invalid
          # Replacing ng-view (via .viewwrap) disables navigation to other pages.
          # This is hideous technique and you, reader, should not copy it.
          $('.viewwrap').before '<div><p class="cheater">There is a problem with your system clock.</p><p>If you don\'t know why you\'re seeing this, <a target="_blank" href=\"http://www.reddit.com/r/swarmsim\">ask about it here</a>.</p></div>'
          $('.viewwrap').css({display:'none'})
          $('.footer').css({display:'none'})
          $interval.cancel enforceInterval
      ->
        console.warn 'failed to check net time'
      )
  enforceInterval = $interval enforce, 1000 * 60 * 30

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.session.exportSave()}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"
    #"https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform"
  
  $scope.isNonprod = ->
    $scope.env and $scope.env != 'prod'
