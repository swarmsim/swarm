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
angular.module('swarmApp').controller 'LoadSaveCtrl', ($scope, $log, game, session, version, $location, backfill) ->
  $scope.form = {}

  # http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = ($event) ->
    $event.target.select()

  $scope.contactUrl = ->
    "#/contact?#{$.param error:$scope.form.error}"

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

  backfill.run game

angular.module('swarmApp').controller 'WelcomeBackCtrl', ($scope, $log, $interval, game) ->
  # Show the welcome-back screen only if we've been gone for a while, ie. not when refreshing.
  # Do all time-checks for the welcome-back screen *before* scheduling heartbeats/onclose.
  $scope.durationSinceClosed = game.session.durationSinceClosed()
  $scope.showWelcomeBack = $scope.durationSinceClosed.asMinutes() >= 3
  #$scope.showWelcomeBack = true # uncomment for testing!
  reifiedToCloseDiffInSecs = (game.session.dateClosed().getTime() - game.session.date.reified.getTime()) / 1000
  $log.debug 'time since game closed', $scope.durationSinceClosed.humanize(),
    millis:game.session.millisSinceClosed()
    reifiedToCloseDiffInSecs:reifiedToCloseDiffInSecs

  # Store when the game was closed. Try to use the browser's onclose (onunload); that's most precise.
  # It's unreliable though (crashes fail, cross-browser's icky, ...) so use a heartbeat too.
  # Wait until showWelcomeBack is set before doing these, or it'll never show
  $(window).unload -> game.session.onClose()
  $interval (-> game.session.onHeartbeat()), 60000
  game.session.onHeartbeat() # game.session time checks after this point will be wrong

  if not $scope.showWelcomeBack
    return

  $scope.closeWelcomeBack = ->
    $log.debug 'closeWelcomeBack'
    $('#welcomeback').alert('close')
    return undefined #quiets an angular error

  # show all tab-leading units, and three leading generations of meat
  interestingUnits = []
  leaders = 0
  for unit in game.tabs.byName.meat.sortedUnits
    if leaders >= 3
      break
    if !unit.velocity().isZero()
      leaders += 1
      interestingUnits.push unit
  interestingUnits = interestingUnits.concat _.map game.tabs.list, 'leadunit'
  uniq = {}
  $scope.offlineGains = _.map interestingUnits, (unit) ->
    if not uniq[unit.name]
      uniq[unit.name] = true
      countNow = unit.count()
      countClosed = unit._countInSecsFromReified reifiedToCloseDiffInSecs
      countDiff = countNow.minus countClosed
      if countDiff.greaterThan 0
        return unit:unit, val:countDiff
  $scope.offlineGains = (g for g in $scope.offlineGains when g)
