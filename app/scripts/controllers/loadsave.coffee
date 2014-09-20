'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:LoadsaveCtrl
 # @description
 # # LoadsaveCtrl
 # Controller of the swarmApp
 #
 # Loads a saved game upon refresh. If it fails, complain loudly and give the player a chance to recover their broken save.
###
angular.module('swarmApp').controller 'LoadSaveCtrl', ($scope, $log, game, session, version) ->
  $scope.form = {}

  # http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = ($event) ->
    $event.target.select()

  $scope.feedbackUrl = ->
    param = "#{version}|#{window?.navigator?.userAgent}|#{$scope.form.error}|#{$scope.form.export}"
    "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"

  exportedsave = session.getStoredSaveData()
  try
    session.load()
    $log.debug 'Game data loaded successfully.', this
  catch e
    # Couldn't load the user's saved data. 
    if not exportedsave
      # If this is their first visit to the site, that's normal, no problems
      $log.debug "Empty saved data; probably the user's first visit here. Resetting quietly."
      game.reset()
    else
      # Couldn't load an actual real save. Shit.
      $log.warn "Failed to load non-empty saved data! Oh no!"
      # reset, but don't save after resetting. Try to keep the bad data around unless the player takes an action.
      game.reset true
      # show a noisy freakout message at the top of the screen with the exported save
      $scope.form.error = e.message
      $scope.form.export = exportedsave
      # tell analytics
      $scope.$emit 'loadGameFromStorageFailed', e.message
  return game
