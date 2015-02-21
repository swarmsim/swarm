'use strict'

###*
 # @ngdoc overview
 # @name swarmApp
 # @description
 # # swarmApp
 #
 # Main module of the application.
###
angular.module 'swarmApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap',
    # autogenerated files specific to this project
    'swarmEnv', 'swarmSpreadsheetPreload'
    # http://luisfarzati.github.io/angulartics/
    'angulartics', 'angulartics.google.analytics'
    # https://github.com/chieffancypants/angular-hotkeys/
    # TODO: hotkeys disabled for now.
    #'cfp.hotkeys'
  ]
angular.module('swarmApp').config ($routeProvider, env) ->
    if env.isOffline
      return $routeProvider
        .when '/debug',
          templateUrl: 'views/debug.html'
          controller: 'DebugCtrl'
        .when '/changelog',
          templateUrl: 'views/changelog.html'
          controller: 'ChangelogCtrl'
        .when '/iframe/:call',
          templateUrl: 'views/iframe.html'
          controller: 'IframeCtrl'
        .when '/',
          templateUrl: 'views/offline.html'
          controller: 'OfflineCtrl'
        .otherwise
          redirectTo: '/'
    $routeProvider
      .when '/debug',
        templateUrl: 'views/debug.html'
        controller: 'DebugCtrl'
      .when '/options',
        templateUrl: 'views/options.html'
        controller: 'OptionsCtrl'
      .when '/changelog',
        templateUrl: 'views/changelog.html'
        controller: 'ChangelogCtrl'
      .when '/statistics',
        templateUrl: 'views/statistics.html'
        controller: 'StatisticsCtrl'
      .when '/achievements',
        templateUrl: 'views/achievements.html'
        controller: 'AchievementsCtrl'
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/tab/:tab/unit/:unit',
        templateUrl: 'views/unit.html'
        controller: 'MainCtrl'
      .when '/unit/:unit',
        templateUrl: 'views/unit.html'
        controller: 'MainCtrl'
      .when '/tab/:tab',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/iframe/:call',
        templateUrl: 'views/iframe.html'
        controller: 'IframeCtrl'
      .when '/contact',
        templateUrl: 'views/contact.html'
        controller: 'ContactCtrl'
      .when '/cleartheme',
        templateUrl: 'views/cleartheme.html'
        controller: 'ClearthemeCtrl'
      .otherwise
        redirectTo: '/'


angular.module('swarmApp').config (env, $logProvider) ->
  $logProvider.debugEnabled env.isDebugLogged

angular.module('swarmApp').config (env, version) ->
  if env.gaTrackingID and window.ga? and not env.isOffline
    #console.log 'analytics', gaTrackingID
    window.ga 'create', env.gaTrackingID, 'auto'
    # appVersion breaks analytics, presumably because it's mobile-only.
    #window.ga 'set', 'appVersion', version

# http and https use different localstorage, which might confuse folks.
# angular $location doesn't make protocol mutable, so use window.location.
# allow an out for testing, though.
angular.module('swarmApp').run (env, $location, $log) ->
  # ?allowinsecure=0 is false, for example
  falsemap = {0:false,'':false,'false':false}
  allowinsecure = $location.search().allowinsecure ? env.httpsAllowInsecure
  allowinsecure = falsemap[allowinsecure] ? true
  $log.debug 'protocol check', allowinsecure, $location.protocol()
  # $location.protocol() == 'http', but window.location.protocol == 'http:' and you can't assign $location.protocol()
  # NOPE, in firefox there's no ':', https://bugzilla.mozilla.org/show_bug.cgi?id=726779 https://github.com/erosson/swarm/issues/68
  # chrome and IE don't mind the missing ':' though. I'm amazed - IE is supposed to be the obnoxious browser
  if $location.protocol() == 'http' and not allowinsecure
    window.location.protocol = 'https'
    $log.debug "window.location.protocol = 'https:'"

# swarmsim.github.io is the place to play swarmsim standalone, for legacy
# reasons. It'll eventually move to swarmsim.com, but that migration's a long
# process that's not done (or started) yet.
#
# Kongregate uses swarmsim.com - it was implemented later and has no legacy
# savestates to worry about.
#
# I don't want people playing in two standalone locations, juggling savestates.
# There's "Kongregate" and there's "standalone"; no more urls. So, redirect
# standalone visitors from swarmsim.com to swarmsim.github.io until the
# migration's done. One exception: ?noredirect=1, for debugging/power-users.
#
# Github automatically redirects the .github.io address behind swarmsim.com to
# swarmsim.com itself.
#
# Github automatically redirects the naked-domain to www.
angular.module('swarmApp').run ($location, isKongregate) ->
  if (window.location.host == 'swarmsim.com' || window.location.host == 'www.swarmsim.com') and not ($location.search().noredirect or isKongregate())
    window.location.host = 'swarmsim.github.io'

angular.module('swarmApp').run ($rootScope) ->
  $rootScope.floor = (val) -> Math.floor val

# decimal.js does not play nice with tests. hacky workaround.
angular.module('swarmApp').run ($rootScope) ->
  # are we running tests with decimal.js imported?
  if window.module and window.module.exports and not window.Decimal and window.module.exports.random
    window.Decimal = window.module.exports
    delete window.module.exports

angular.module('swarmApp').value 'UNIT_LIMIT', '1e100000'

angular.module('swarmApp').run ($rootScope) ->
  #Decimal.config errors:false
