'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:HeaderCtrl
 # @description
 # # HeaderCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'HeaderCtrl', ($scope, $window, env, version, session, analytics, statistics, timecheck, $http, $interval) ->
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
          # This is hideous technique and you, reader, shouldn't copy it.
          $('.viewwrap').before '<div class="cheater">There is a problem with your system clock.</div>'
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
