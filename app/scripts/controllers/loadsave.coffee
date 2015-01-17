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
angular.module('swarmApp').controller 'LoadSaveCtrl', ($scope, $log, game, session, version, $location) ->
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

  # try to load a save file from the url.
  if (savedata = $location.search().savedata)?
    $log.info 'loading game from url...'
    # transient=true: don't overwrite the saved data until we buy something
    game.importSave savedata, true
    $log.info 'loading game from url successful!'

  # hacky 0.2.11 fix. TODO remove
  for i in [1..5]
    $log.debug 'nexusfix', i, game.upgrade("nexus#{i}").count(), game.unit('nexus').count()
    if game.upgrade("nexus#{i}").count() > 0 and game.unit('nexus').count() < i
      $log.info 'fixed nexus count', i
      game.unit('nexus')._setCount i

  # grant mutagen for old saves
  do ->
    premutagen = game.unit 'premutagen'
    ascension = game.unit 'ascension'
    hatchery = game.upgrade 'hatchery'
    expansion = game.upgrade 'expansion'
    minlevel = game.unit('invisiblehatchery').stat 'random.minlevel'
    # at minlevel hatcheries/expos, premutagen is always granted. if it wasn't - no ascensions and no premutagen -
    # this must be an old save, they got the upgrades before mutagen existed.
    if premutagen.count() == ascension.count() == 0 and (hatchery.count() >= minlevel or expansion.count() >= minlevel)
      $log.info 'backfilling mutagen for old save'
      for up in [hatchery, expansion]
        for i in [0...up.count()]
          for e in up.effect
            e.onBuy i + 1
    else
      $log.debug 'no mutagen backfill necessary'
