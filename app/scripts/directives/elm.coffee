'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:elm
 # @description
 # # elm
###
angular.module 'swarmApp'
  .directive 'elm', ->
    restrict: 'EA'
    template: """
    <div ng-if="status == 'beta'" class="alert alert-info" role="alert">
      <button ng-click="close()" class="close pull-right btn"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
      <p>Swarm Simulator's next big update will be ready soon. <a href="{{host}}{{query}}">Want to try it out today?</a></p>
    </div>
    <div ng-if="status == 'legacy'" class="alert alert-danger" role="alert">
      <button ng-click="close()" class="close pull-right btn"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
      <p>Swarm Simulator's been updated, and you're playing an old version. <a href="{{host}}{{query}}">You should play the latest Swarm Simulator!</a></p>
      <p>Is something broken? Hate the new version? Please <a href="#/contact">contact the developer</a>.</p>
    </div>
    """
    link: (scope, element, attrs) ->
      # scope.host = "https://localhost:3001"
      scope.host = "https://elm.swarmsim.com"
      # preserve kongregate's querystring, among other things
      scope.query = document.location.search

      # A crude localstorage-based gradual-rollout framework.
      # I'll store a random number at this localstorage key, and `enablePct`
      # percent of users will see it active. 0 <= enablePct <= 1.
      # "0.1" returns true for 10% of users; "0" no users; "1" all users.
      # To roll out to more users, increase `enablePct` - code release required.
      rollout = (key, enablePct) ->
        storage = localStorage.getItem(key)
        if storage?
          roll = parseFloat(storage)
        else
          roll = Math.random()
          localStorage.setItem key, roll
        val = roll >= (1 - enablePct)
        #if !storage?
        #  console.log 'rollout init', key, roll, val
        return val

      # valid statuses:
      # * hidden: nothing is shown. Message was manually closed, or the elm
      #   opt-in isn't publically visible yet.
      # * beta: opt-in message is shown. Use this while coffeescript's still
      #   running on www.swarmsim.com.
      # * legacy: opt-out message/link are shown. Use this once coffeescript's
      #   *not* running on www.swarmsim.com, only on coffee.swarmsim.com.
      scope.status = if rollout('rollout:elm', 0) then 'beta' else 'hidden'
        # next phase:
        # 'beta'
        # final phase:
        # 'legacy'
      scope.close = ->
        scope.status = 'hidden'
