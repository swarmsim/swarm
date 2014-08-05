'use strict'

###*
 # @ngdoc function
 # @name swarmApp.decorator:Exceptionhandler
 # @description
 # # Exceptionhandler
 # Decorator of the swarmApp
###
angular.module("swarmApp").config ($provide) ->
  $provide.decorator "$exceptionHandler", ($delegate, $analytics, session) ->
    simpleEvent = (exception, cause) ->
      action = 'unhandled-exception'
      label = "#{exception}"
      opts = category:'error', label:label
      $analytics.eventTrack action, opts
      console.log 'simple error sent to google-analytics', action, opts

    detailedEvent = (exception, cause) ->
      # try to log the state of the game
      try
        savestate = session.jsonSaves()
        # It's a JSON string. We're stringifying later, so parse it to avoid double-stringifying.
        try
          savestate = JSON.parse savestate
        catch thriceasscrewed
          # darn, it'll double-stringify. not the end of the world.
      catch twiceasscrewed
        savestate = "Couldn't log game state: #{twiceasscrewed}"
      # strings are required for action, label. Abuse label to store session state.
      # It has a 500byte length limit, so it'll probably break:
      # https://developers.google.com/analytics/devguides/collection/analyticsjs/field-reference
      action = "Unhandled exception: #{exception}"
      label = JSON.stringify cause:cause, savestate:savestate
      opts = category:'error', label:label
      $analytics.eventTrack action, opts
      console.log 'detailed error sent to google-analytics', action, opts

    return (exception, cause) ->
      $delegate exception, cause
      #simpleEvent exception, cause
      detailedEvent exception, cause
      ga 'send', 'exception',
        exDescription: "#{exception}"
