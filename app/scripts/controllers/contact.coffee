'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:FeedbackCtrl
 # @description
 # # FeedbackCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'ContactCtrl', ($scope, feedback, version, $location, isKongregate) ->
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

  $scope.subject = ->
    "Swarm Simulator Feedback (#{new Date().toLocaleString()})"
  source = if isKongregate() then "Kongregate" else "Standalone"
  $scope.message = -> """
Type your message here.

*****

Bug report information:

* Swarm Simulator version: #{version}
* Saved game: #{$scope.urls.expand}
* Source: #{source}
* Browser: #{$scope.userAgentGuess}#{
if $location.search().error then "\n* Error message: ```"+$location.search().error+'```' else ''}
"""
  #* Full user agent: https://www.whatismybrowser.com/developers/custom-parse?useragent=#{encodeURIComponent window?.navigator?.userAgent}

  $scope.redditUrl = ->
    "https://www.reddit.com/message/compose/?to=kawaritai&subject=#{encodeURIComponent $scope.subject()}&message=#{encodeURIComponent $scope.message()}"

  $scope.emailTo = ->
    # because spam
    LZString.decompressFromBase64 'GYUxBMCMEMGMGsACBnA7tATgW2QSywHSwD2WQA=='
    
  $scope.mailtoUrl = ->
    "mailto:#{$scope.emailTo()}?subject=#{encodeURIComponent $scope.subject()}&body=#{encodeURIComponent $scope.message()}"

  $scope.anonForm = ->
    if (error = $location.search().error or '')
      error += '|'
    baseurl = "https://docs.google.com/a/swarmsim.com/forms/d/18ywqkqMlviAgKACVZUI6XkaGte2piKN3LGbii8Qwvmw/viewform?entry.1461412788="
    param = "#{version}|#{$scope.userAgentGuess}|#{error}#{$scope.urls.expand}"
    url = "#{baseurl}#{encodeURIComponent param}"
    # starts throwing bad requests for length around this point. Send whatever we can.
    LIMIT = 1950
    if url.length > LIMIT
      url = url.substring(0,LIMIT) + encodeURIComponent "...TRUNCATED..."
    return url

