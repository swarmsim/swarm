/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:FeedbackCtrl
 * @description
 * # FeedbackCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('ContactCtrl', function($scope, feedback, version, $location, isKongregate, $log, $sce) {
  let emailTo;
  $scope.urls = {short:'???',expand:'???'};
  $scope.userAgentGuess = (() => {
    // based on http://odyniec.net/blog/2010/09/decrypting-the-user-agent-string-in-javascript/
    const browsers = [
      {name: 'Chrome', regex: /Chrome\/(\S+)/},
      {name: 'Firefox', regex: /Firefox\/(\S+)/},
      {name: 'MSIE', regex: /MSIE (\S+);/},
      {name: 'Opera', regex: /Opera\/(\S+)/},
      {name: 'Safari', regex: /Version\/(\S+).*?Safari\//}
      ];
    const ua = __guard__(typeof window !== 'undefined' && window !== null ? window.navigator : undefined, x => x.userAgent);
    for (var browser of Array.from(browsers)) {
      var m;
      if (m = ua.match(browser.regex)) {
        return `${browser.name} ${m[1]}`;
      }
    }
    return ua;
  })();

  feedback.createTinyurl().done((data, status, xhr) => {
    $scope.urls.short = data.id;
    return $scope.urls.expand = data.id + '+';
  });

  $scope.initTopic = ($location.search().error != null) ? 'bug' : undefined;

  // has an actual error message - `?error=blah`, not just `?error`.
  // `"an error message" != true`
  const hasErrorMessage = $location.search().error && ($location.search().error !== true);
  const topics = {
    bug: {
      subject() { return `Swarm Simulator Bug Report (${new Date().toLocaleString()})`; },
      message() { return `\
Describe the bug here. Step-by-step instructions saying how to make the bug reoccur are helpful.

*****

Bug report information:

* Swarm Simulator version: ${version}
* Source: ${isKongregate() ? "Kongregate" : "Standalone"}
* Browser: ${$scope.userAgentGuess}${
hasErrorMessage ? "\n* Error message: ```"+$location.search().error+'```' : ''}\
`; },
//* Full user agent: https://www.whatismybrowser.com/developers/custom-parse?useragent=#{encodeURIComponent window?.navigator?.userAgent}
      anonDebug() {
        let error;
        if (error = $location.search().error || '') {
          error += '|';
        }
        return `${version}|${$scope.userAgentGuess}|${error}${$scope.urls.expand}`;
      }
    },
    other: {
      subject() { return `Swarm Simulator Feedback (${new Date().toLocaleString()})`; },
      message() { return ''; },
      anonDebug() { return ''; },
      emailTo() {
        // because spam
        return LZString.decompressFromBase64('GYUxBMCMEMGMGsACBnA7tATgW2QSywHSwD2WQA==');
      }
    }
  };

  const _get = (topic, key) => ((topics[topic] != null ? topics[topic][key] : undefined) != null ? (topics[topic] != null ? topics[topic][key] : undefined) : topics.other[key])();
  const subject = topic => _get(topic, 'subject');
  const message = topic => _get(topic, 'message');
  const anonDebug = topic => _get(topic, 'anonDebug');
  $scope.emailTo = (emailTo = topic => _get(topic, 'emailTo'));
  $scope.redditUrl = topic => `https://www.reddit.com/message/compose/?to=kawaritai&subject=${encodeURIComponent(subject(topic))}&message=${encodeURIComponent(message(topic))}`;
  $scope.mailtoUrl = function(topic) {
    const qs = window.Qs.stringify({
      subject: subject(topic),
      body: message(topic)
    });
    return `mailto:${emailTo(topic)}?${qs}`;
  };
  return $scope.anonForm = function(topic) {
    let url = `https://docs.google.com/a/swarmsim.com/forms/d/18ywqkqMlviAgKACVZUI6XkaGte2piKN3LGbii8Qwvmw/viewform?entry.1461412788=${encodeURIComponent(anonDebug(topic))}`;
    // starts throwing bad requests for length around this point. Send whatever we can.
    const LIMIT = 1950;
    if (url.length > LIMIT) {
      url = url.substring(0,LIMIT) + encodeURIComponent("...TRUNCATED...");
    }
    return url;
  };
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}