/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import $ from 'jquery';

/**
 * @ngdoc function
 * @name swarmApp.controller:LoadsaveCtrl
 * @description
 * # LoadsaveCtrl
 * Controller of the swarmApp
 *
 * Loads a saved game upon refresh. If it fails, complain loudly and give the player a chance to recover their broken save.
*/
angular.module('swarmApp').controller('LoadSaveCtrl', function($scope, $log, game, session, version, $location, backfill, isKongregate, storage, saveId) {
  let e, exportedsave, savedata;
  $scope.form = {};
  $scope.isKongregate = isKongregate;

  // http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = $event => $event.target.select();

  $scope.contactUrl = () => `#/contact?${$.param({error:$scope.form.error})}`;

  try {
    exportedsave = session.getStoredSaveData();
  } catch (error) {
    e = error;
    $log.error("couldn't even read localstorage! oh no!", e);
    game.reset(true);
    // show a noisy freakout message at the top of the screen with the exported save
    $scope.form.errored = true;
    $scope.form.error = e.message;
    $scope.form.domain = window.location.host;
    // tell analytics
    $scope.$emit('loadGameFromStorageFailed', e.message);
    return;
  }

  try {
    session.load();
    $log.debug('Game data loaded successfully.', this);
  } catch (error1) {
    // Couldn't load the user's saved data.
    e = error1;
    if (!exportedsave) {
      // If this is their first visit to the site, that's normal, no problems
      $log.debug("Empty saved data; probably the user's first visit here. Resetting quietly.");
      game.reset(true); //but don't save, in case we're waiting for flash recovery
      //# listen for flash to load - loading it takes extra time, but we might find a save there.
      //storage.flash.onReady.then ->
      //  encoded = storage.flash.getItem saveId
      //  if encoded
      //    $log.debug "flash loaded successfully, and found a saved game there that wasn't in cookies/localstorage! importing."
      //    # recovered save from flash! tell analytics
      //    $scope.$root.$broadcast 'savedGameRecoveredFromFlash', e.message
      //    game.importSave encoded, true # don't save when recovering from flash - if this is somehow a mistake, player can take no action
      //  else
      //    $log.debug 'flash loaded successfully, but no saved game found. this is truly a new visitor.'
    } else {
      // Couldn't load an actual real save. Shit.
      $log.warn("Failed to load non-empty saved data! Oh no!");
      // reset, but don't save after resetting. Try to keep the bad data around unless the player takes an action.
      game.reset(true);
      // show a noisy freakout message at the top of the screen with the exported save
      $scope.form.errored = true;
      $scope.form.error = e.message;
      $scope.form.export = exportedsave;
      // tell analytics
      $scope.$emit('loadGameFromStorageFailed', e.message);
    }
  }

  // try to load a save file from the url.
  if ((savedata = $location.search().savedata) != null) {
    const ts = $location.search().ts && new Date(parseInt($location.search().ts));
    // If there is no timestamp, import the game. If there is one, verify that we're probably not nuking the same game-in-progress.
    // If the current game was updated *before* the imported game was updated, accept the import - import is newer.
    // If the current game was started *after* the imported game was updated, accept the import - it's probably deliberate, or it's a new game.
    if (!ts || (session.state.date.reified < ts) || (session.state.date.started > ts)) {
      $log.info('loading game from url...');
      // transient=true: don't overwrite the saved data until we buy something
      game.importSave(savedata, true);
      $log.info('loading game from url successful!');
    } else {
      $log.info("ignoring game in url, imported timestamp shouldn't overwrite current game", ts, session.state.date);
    }
  }

  return backfill.run(game);
});

angular.module('swarmApp').controller('AprilFoolsCtrl', function($scope, options) {
  $scope.options = options;
  return $scope.year = new Date().getFullYear();
});

angular.module('swarmApp').controller('WelcomeBackCtrl', function($scope, $log, $interval, game, $location) {
  let run;
  let interval = null;
  $scope.$on('import', function(event, args) {
    $log.debug('welcome back: import', args != null ? args.success : undefined, args);
    if (args != null ? args.success : undefined) {
      return run(true, true);
    }
  });
  $scope.$on('savedGameRecoveredFromFlash', function(event, args) {
    $log.debug('welcome back: saved game recovered from flash');
    return run();
  });
  $scope.$on('reset', (event, args) => (typeof $scope.closeWelcomeBack === 'function' ? $scope.closeWelcomeBack() : undefined) != null);
  return (run = function(force, ignoreHeartbeat) {
    // Show the welcome-back screen only if we've been gone for a while, ie. not when refreshing.
    // Do all time-checks for the welcome-back screen *before* scheduling heartbeats/onclose.
    $scope.durationSinceClosed = game.session.durationSinceClosed(undefined, ignoreHeartbeat);
    $scope.showWelcomeBack = ($scope.durationSinceClosed.asMinutes() >= 3) || $location.search().forcewelcome;
    const reifiedToCloseDiffInSecs = (game.session.dateClosed(ignoreHeartbeat).getTime() - game.session.state.date.reified.getTime()) / 1000;
    $log.debug('time since game closed', $scope.durationSinceClosed.humanize(), {
      millis:game.session.millisSinceClosed(undefined, ignoreHeartbeat),
      reifiedToCloseDiffInSecs
    }
    );

    // Store when the game was closed. Try to use the browser's onclose (onunload); that's most precise.
    // It's unreliable though (crashes fail, cross-browser's icky, ...) so use a heartbeat too.
    // Wait until showWelcomeBack is set before doing these, or it'll never show
    $(window).on('unload', () => game.session.onClose());
    if (interval == null) { interval = $interval((() => game.session.onHeartbeat()), 60000); }
    game.session.onHeartbeat(); // game.session time checks after this point will be wrong

    if (!$scope.showWelcomeBack) {
      $log.debug('skipping welcome back screen: offline time too short', $scope.durationSinceClosed.asMinutes());
      return;
    }

    $scope.closeWelcomeBack = function() {
      $log.debug('closeWelcomeBack');
      $('#welcomeback').alert('close');
      return undefined; //quiets an angular error
    };

    // show all tab-leading units, and three leading generations of meat
    let interestingUnits = [];
    let leaders = 0;
    for (var unit of Array.from(game.tabs.byName.meat.sortedUnits)) {
      if (leaders >= 3) {
        break;
      }
      if (!unit.velocity().isZero()) {
        leaders += 1;
        interestingUnits.push(unit);
      }
    }
    interestingUnits = interestingUnits.concat(_.map(game.tabs.list, 'leadunit'));
    const uniq = {};
    $scope.offlineGains = _.map(interestingUnits, function(unit) {
      if (!uniq[unit.name]) {
        uniq[unit.name] = true;
        const countNow = unit.count();
        const countClosed = unit._countInSecsFromReified(reifiedToCloseDiffInSecs);
        const countDiff = countNow.minus(countClosed);
        if (countDiff.greaterThan(0)) {
          return {unit, val:countDiff};
        }
      }
    });
    return $scope.offlineGains = (Array.from($scope.offlineGains).filter((g) => g));
  })(false, false);
});
