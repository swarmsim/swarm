'use strict'
# TODO
import * as views from '../views'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'wwwPlayfab', (playfab, wwwPlayfabSyncer) ->
  # <div ng-include="'views/playfab/title.html'"></div>
  template: """
<div ng-if="isVisible()">
  <playfabauth ng-if="!isAuthed()"></playfabauth>
  <playfaboptions ng-if="isAuthed()"></playfaboptions>
</div>
"""
  restrict: 'EA'
  scope: {}
  link: (scope, element, attrs) ->
    scope.isVisible = -> wwwPlayfabSyncer.isVisible()
    scope.isAuthed = -> playfab.isAuthed()

# this is pretty ugly. Mostly copied/modified from the old KongregateS3Ctrl
angular.module('swarmApp').directive 'kongregatePlayfab', ($log, env, kongregate, kongregateS3Syncer, kongregatePlayfabSyncer, options, $timeout) ->
  # <div ng-include="'views/playfab/kongregate.html'"></div>
  template: """
<div ng-if="isVisible">
</div>
"""
  restrict: 'EA'
  scope: {}
  link: (scope, element, attrs) ->
    # This switches Kongregate's online-save backend from S3 to Playfab. Compare with kongregateS3Ctrl. Soon, we'll kill the S3 backend.
    syncer = kongregatePlayfabSyncer
    # http://www.kongregate.com/pages/general-services-api
    scope.kongregate = kongregate
    scope.env = env
    scope.options = options
    if !env.isKongregateSyncEnabled or !kongregate.isKongregate()
      return
    clear = scope.$watch 'kongregate.kongregate', (newval, oldval) ->
      if newval?
        clear()
        onload()

    scope.isVisible = syncer.isVisible()
    scope.isGuest = ->
      return !scope.api? or scope.api.isGuest()
    scope.saveServerUrl = env.saveServerUrl
    scope.remoteSave = -> syncer.fetchedSave()
    scope.remoteDate = -> syncer.fetchedDate()
    scope.getAutopushError = -> syncer.getAutopushError()

    onload = ->
      scope.api = kongregate.kongregate.services
      scope.api.addEventListener 'login', (event) ->
        scope.$apply()
      scope.init()

    scope.isBrowserSupported = -> window.FormData? and window.Blob?

    cooldown = scope.cooldown =
      byName: {}
      set: (name, wait=5000) ->
        cooldown.byName[name] = $timeout (-> cooldown.clear name), wait
      clear: (name) ->
        if cooldown.byName[name]
          $timeout.cancel cooldown.byName[name]
          delete cooldown.byName[name]

    scope.init = (force) ->
      scope.policyError = null
      cooldown.set 'init'
      syncer.init()

    scope.fetch = ->
      cooldown.set 'fetch'
      syncer.fetch().then(
        (result) ->
          cooldown.clear 'fetch'
          $log.debug 'kong syncer fetched', result, syncer
          #scope.$apply()
        (error) ->
          cooldown.clear 'fetch'
          # 404 is fine. no game saved yet
          if data.status != 404
            scope.policyError = "Failed to fetch remote saved game: #{data?.status}, #{data?.statusText}, #{data?.responseText}"
          #scope.$apply()
      )

    scope.push = ->
      cooldown.set 'push'
      syncer.push().then(
        (res) ->
          cooldown.clear 'push'
          #scope.$apply()
        (error) ->
          cooldown.clear 'push'
          scope.policyError = "Error pushing remote saved game: #{error}"
          #scope.$apply()
      )

    scope.pull = ->
      syncer.pull()

    scope.clear = ->
      if (!confirm("Once online data's deleted, there's no undo. Are you sure?")) then return
      cooldown.set 'clear'
      syncer.clear().then(
        (res) ->
          cooldown.clear 'clear'
          #scope.$apply()
        (error) ->
          cooldown.clear 'clear'
          scope.policyError = "Error clearing remote saved game: #{error}"
          #scope.$apply()
      )
