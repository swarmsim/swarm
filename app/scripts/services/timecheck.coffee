'use strict'

###*
 # @ngdoc service
 # @name swarmApp.timecheck
 # @description
 # # timecheck
 # Factory in the swarmApp.
 #
 # Players can cheat by messing with their system clock. This is ultimately
 # unavoidable, but we can make it a little harder by asking the internet
 # what time it really is. This will fail sometimes, and that's okay - we
 # don't have to be 100% secure. It's better to reset only when we're sure
 # than to nuke someone innocent.
###
angular.module('swarmApp').factory 'TimeChecker', ($rootScope, $http, $q, timecheckUrl, session, game) -> class TimeChecker
  constructor: (thresholdHours) ->
    @threshold = moment.duration thresholdHours, 'hours'

  fetchNetTime: ->
    # returns a promise
    #$http.jsonp timecheckUrl
    $http.head timecheckUrl

  # 'invalid' vs 'valid' is deliberate: false means it might be valid or
  # there might have been an error while checking, while true means we're
  # pretty sure they're cheating
  isNetTimeInvalid: ->
    @fetchNetTime().then(
      (res) =>
        #@_isNetTimeInvalid res.date
        @_isNetTimeInvalid res.headers().date
      (res) =>
        #console.warn 'fetchnettime promise failed', res
        $rootScope.$emit 'timecheckError', {error:'fetchNetTime promise failed', res:res}
        $q.reject res
      )

  _isNetTimeInvalid: (netnowString, now=moment()) ->
    netnow = moment new Date netnowString
    diff = now.diff netnow, 'hours'
    return Math.abs(diff) > @threshold.as 'hours'

  enforceNetTime: ->
    @isNetTimeInvalid().then (invalid) =>
      if invalid
        # they're cheating, no errors
        $rootScope.$emit 'timecheckFailed'
        #game.reset() # not confident enough to do this yet, but we can disable the ui until analytics tells us more.
      return invalid
  
#angular.module('swarmApp').value 'timecheckUrl', 'http://json-time.appspot.com/time.json?callback=JSON_CALLBACK'
angular.module('swarmApp').value 'timecheckUrl', '/'
# Threshold at which a player is assumed to be timewarp-cheating
angular.module('swarmApp').value 'timecheckThresholdHours', 24 * 4

angular.module('swarmApp').factory 'timecheck', (TimeChecker, timecheckThresholdHours) ->
  new TimeChecker timecheckThresholdHours
