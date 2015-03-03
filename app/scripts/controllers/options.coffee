'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:OptionsCtrl
 # @description
 # # OptionsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, session, game, env, $log, backfill, isKongregate, storage) ->
  $scope.options = options
  $scope.game = game
  $scope.session = session
  $scope.env = env
  $scope.imported = {}

  $scope.isKongregate = isKongregate
  # A dropbox key must be supplied, no exceptions.
  # Dropbox can be disabled per-environment in the gruntfile. It's disabled on Kongregate per their (lame) rules.
  # ?dropbox in the URL overrides these things.
  $scope.isDropbox = env.dropboxAppKey and ($location.search().dropbox ?
    (env.isDropboxEnabled and not isKongregate()))

  $scope.duration_examples = [
      moment.duration(16,'seconds')
      moment.duration(163,'seconds')
      moment.duration(2.5,'hours')
      moment.duration(3.33333333,'weeks')
      moment.duration(2.222222222222,'months')
      moment.duration(1.2,'year')
  ];

  $scope.form =
    isCustomTheme: options.theme().isCustom
    customThemeUrl: options.theme().url
    theme: options.theme().name
  $scope.setTheme = (name) ->
    $scope.options.theme name
    $scope.form.isCustomTheme = false
  $scope.selectCustomTheme = ->
    $scope.form.isCustomTheme = true
    $scope.form.customThemeUrl = ''
  $scope.setCustomTheme = (url) ->
    console.log 'setcustomtheme', url
    $scope.options.customTheme url

  # http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = ($event) ->
    $event.target.select()

  savedDataDetails = (store) ->
    try
      encoded = store.storage.getItem session.id
    catch e
      $log.debug 'error loading saveddatadetails from storage, continuing', store.name, e
    ret =
      name: store.name
      exists: encoded?
    if encoded?
      ret.size = encoded.length
    return ret
  $scope.savedDataDetails = (savedDataDetails(store) for store in storage.storages.list)
  if !storage.flash.isReady?
    storage.flash.onReady.then =>
      $scope.savedDataDetails = (savedDataDetails(store) for store in storage.storages.list)

  $scope.importSave = (encoded) ->
    $scope.imported = {}
    try
      $scope.game.importSave encoded
      backfill.run $scope.game
      $scope.imported.success = true
      $scope.$emit 'import', {success:true}
      $log.debug 'import success'
    catch e
      $scope.imported.error = true
      $scope.$emit 'import', {success:false}
      $log.warn 'import error', e

  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. No reset-bonuses here. You sure?'
      # delete all storage, as advertised
      storage.removeItem session.id
      $scope.game.reset true
      $location.url '/'
