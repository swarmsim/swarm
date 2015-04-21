'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:FeedbackCtrl
 # @description
 # # FeedbackCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ContactCtrl', ($scope, feedback, version, $location, isKongregate, $log) ->
  $scope.urls = {short:'???',expand:'???'}
  $scope.userAgentGuess = do =>
    # based on http://odyniec.net/blog/2010/09/decrypting-the-user-agent-string-in-javascript/
    browsers = [
      {name: 'Chrome', regex: /Chrome\/(\S+)/}
      {name: 'Firefox', regex: /Firefox\/(\S+)/}
      {name: 'MSIE', regex: /MSIE (\S+);/}
      {name: 'Opera', regex: /Opera\/(\S+)/}
      {name: 'Safari', regex: /Version\/(\S+).*?Safari\//}
      ]
    ua = window?.navigator?.userAgent
    for browser in browsers
      if (m = ua.match browser.regex)
        return "#{browser.name} #{m[1]}"
    return ua

  feedback.createTinyurl().done (data, status, xhr) =>
    $scope.urls.short = data.id
    $scope.urls.expand = data.id + '+'

  $scope.initTopic = if $location.search().error? then 'bug'
    
  # has an actual error message - `?error=blah`, not just `?error`.
  # `"an error message" != true`
  hasErrorMessage = $location.search().error and $location.search().error != true
  topics =
    bug:
      subject: -> "Swarm Simulator Bug Report (#{new Date().toLocaleString()})"
      message: -> """
Describe the bug here. Step-by-step instructions saying how to make the bug reoccur are helpful.

*****

Bug report information:

* Swarm Simulator version: #{version}
* Saved game: #{$scope.urls.expand}
* Source: #{if isKongregate() then "Kongregate" else "Standalone"}
* Browser: #{$scope.userAgentGuess}#{
if hasErrorMessage then "\n* Error message: ```"+$location.search().error+'```' else ''}
"""
#* Full user agent: https://www.whatismybrowser.com/developers/custom-parse?useragent=#{encodeURIComponent window?.navigator?.userAgent}
      anonDebug: ->
        if (error = $location.search().error or '')
          error += '|'
        return "#{version}|#{$scope.userAgentGuess}|#{error}#{$scope.urls.expand}"
    other:
      subject: -> "Swarm Simulator Feedback (#{new Date().toLocaleString()})"
      message: -> ''
      anonDebug: -> ''
      emailTo: ->
        # because spam
        LZString.decompressFromBase64 'GYUxBMCMEMGMGsACBnA7tATgW2QSywHSwD2WQA=='

  _get = (topic, key) ->
    (topics[topic]?[key] ? topics.other[key])()
  subject = (topic) -> _get topic, 'subject'
  message = (topic) -> _get topic, 'message'
  anonDebug = (topic) -> _get topic, 'anonDebug'
  $scope.emailTo = emailTo = (topic) -> _get topic, 'emailTo'
  $scope.redditUrl = (topic) ->
    "https://www.reddit.com/message/compose/?to=kawaritai&subject=#{encodeURIComponent subject topic}&message=#{encodeURIComponent message topic}"
  $scope.mailtoUrl = (topic) ->
    "mailto:#{emailTo topic}?subject=#{encodeURIComponent subject topic}&body=#{encodeURIComponent message topic}"
  $scope.anonForm = (topic) ->
    url = "https://docs.google.com/a/swarmsim.com/forms/d/18ywqkqMlviAgKACVZUI6XkaGte2piKN3LGbii8Qwvmw/viewform?entry.1461412788=#{encodeURIComponent anonDebug topic}"
    # starts throwing bad requests for length around this point. Send whatever we can.
    LIMIT = 1950
    if url.length > LIMIT
      url = url.substring(0,LIMIT) + encodeURIComponent "...TRUNCATED..."
    return url

