/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:OptionsCtrl
 * @description
 * # OptionsCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('OptionsCtrl', function($scope, $location, options, session, game, env, $log, backfill, isKongregate, storage, feedback) {
  let store;
  $scope.options = options;
  $scope.game = game;
  $scope.session = session;
  $scope.env = env;
  $scope.imported = {};

  $scope.isKongregate = isKongregate;

  $scope.duration_examples = [
      moment.duration(16,'seconds'),
      moment.duration(163,'seconds'),
      moment.duration(2.5,'hours'),
      moment.duration(3.33333333,'weeks'),
      moment.duration(2.222222222222,'months'),
      moment.duration(1.2,'year')
  ];

  $scope.form = {
    isCustomTheme: options.theme().isCustom,
    customThemeUrl: options.theme().url,
    theme: options.theme().name,
    themeExtra: options.themeExtra(),
    isThemeExtraOpen: !!options.themeExtra(),
    iframeMinSize: {
      x: options.iframeMinX(),
      y: options.iframeMinY()
    }
  };
  $scope.setFpsSlider = function(fps) {
    // slider rounding shouldn't overwrite decimals from fpsNum
    if (Math.abs(options.fps() - fps) >= 1) {
      options.fps(fps);
      return $scope.form.fpsNum = options.fps();
    }
  };
  $scope.setTheme = function(name) {
    $scope.options.theme(name);
    return $scope.form.isCustomTheme = false;
  };
  $scope.selectCustomTheme = function() {
    $scope.form.isCustomTheme = true;
    return $scope.form.customThemeUrl = '';
  };
  $scope.setCustomTheme = function(url) {
    console.log('setcustomtheme', url);
    return $scope.options.customTheme(url);
  };

  // http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = $event => $event.target.select();
  $scope.copy = function($event) {
    document.execCommand('copy');
    const ex = document.getElementById('export');
    ex.focus();
    ex.select();
    return document.execCommand('copy');
  };

  const savedDataDetails = function(store) {
    let encoded;
    try {
      encoded = store.storage.getItem(session.id);
    } catch (e) {
      $log.debug('error loading saveddatadetails from storage, continuing', store.name, e);
    }
    const ret = {
      name: store.name,
      exists: (encoded != null)
    };
    if (encoded != null) {
      ret.size = encoded.length;
    }
    return ret;
  };
  $scope.savedDataDetails = ((() => {
    const result = [];
    for (store of Array.from(storage.storages.list)) {       result.push(savedDataDetails(store));
    }
    return result;
  })());

  $scope.importSave = function(encoded) {
    // don't try to import short urls
    if (encoded && (encoded.indexOf('http') === 0)) {
      return;
    }
    $scope.imported = {};
    try {
      $scope.game.importSave(encoded);
      backfill.run($scope.game);
      $scope.imported.success = true;
      $scope.$root.$broadcast('import', {source:'options',success:true});
      return $log.debug('import success');
    } catch (e) {
      $scope.imported.error = true;
      $scope.$root.$broadcast('import', {source:'options',success:false});
      return $log.warn('import error', e);
    }
  };

  $scope.confirmReset = function() {
    if (confirm('You will lose everything and restart the game. No reset-bonuses here. You sure?')) {
      // delete all storage, as advertised
      storage.removeItem(session.id);
      $scope.game.reset(true);
      return $location.url('/');
    }
  };

  $scope.clearThemeExtra = function() {
    $scope.form.themeExtraSuccess = null;
    return $scope.form.themeExtraError = null;
  };
  $scope.themeExtra = function(text) {
    $scope.clearThemeExtra();
    try {
      options.themeExtra(text);
      return $scope.form.themeExtraSuccess = true;
    } catch (e) {
      $log.error(e);
      $scope.form.themeExtraError = e != null ? e.message : undefined;
      return;
    }
  };
    //$log.debug 'themeExtra updates', themeExtraEl

  $scope.isDefaultMinSize = () => ($scope.form.iframeMinSize.x === $scope.options.constructor.IFRAME_X_MIN) &&
    ($scope.form.iframeMinSize.y === $scope.options.constructor.IFRAME_Y_MIN);
  return $scope.resetMinSize = function() {
    $scope.options.iframeMinX($scope.form.iframeMinSize.x = $scope.options.constructor.IFRAME_X_MIN);
    return $scope.options.iframeMinY($scope.form.iframeMinSize.y = $scope.options.constructor.IFRAME_Y_MIN);
  };
});
