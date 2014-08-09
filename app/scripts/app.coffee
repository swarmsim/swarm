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
    'ngTouch'
    # http://luisfarzati.github.io/angulartics/
    'angulartics', 'angulartics.google.analytics'
  ]
angular.module('swarmApp').config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .when '/debug',
        templateUrl: 'views/debug.html'
        controller: 'DebugCtrl'
      .when '/demo',
        templateUrl: 'views/demo.html'
        controller: 'DemoCtrl'
      .when '/unitlist',
        templateUrl: 'views/unitlist.html'
        controller: 'UnitlistCtrl'
      .when '/unitlist/:unit',
        templateUrl: 'views/unitlist.html'
        controller: 'UnitlistCtrl'
      .otherwise
        redirectTo: '/'

# start ticking on load. loading schedule begins ticks.
angular.module('swarmApp').run (schedule) ->
