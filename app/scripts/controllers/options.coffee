'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:OptionsCtrl
 # @description
 # # OptionsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'OptionsCtrl', ($scope, $location, options, session, game, env, $log, backfill, isKongregate, storage, feedback, dropboxSyncer) ->
  $scope.options = options
  $scope.game = game
  $scope.session = session
  $scope.env = env
  $scope.imported = {}

  $scope.isKongregate = isKongregate
  $scope.isDropbox = dropboxSyncer.isVisible()

  $scope.duration_examples = [
      moment.duration(16,'seconds')
      moment.duration(163,'seconds')
      moment.duration(2.5,'hours')
      moment.duration(3.33333333,'weeks')
      moment.duration(2.222222222222,'months')
      moment.duration(1.2,'year')
  ]

  $scope.form =
    isCustomTheme: options.theme().isCustom
    customThemeUrl: options.theme().url
    theme: options.theme().name
    themeExtra: options.themeExtra()
    isThemeExtraOpen: !!options.themeExtra()
    iframeMinSize:
      x: options.iframeMinX()
      y: options.iframeMinY()
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
    # don't try to import short urls
    if encoded and encoded.indexOf('http') == 0
      return
    $scope.imported = {}
    try
      $scope.game.importSave encoded
      backfill.run $scope.game
      $scope.imported.success = true
      $scope.$root.$broadcast 'import', {source:'options',success:true}
      $log.debug 'import success'
    catch e
      $scope.imported.error = true
      $scope.$root.$broadcast 'import', {source:'options',success:false}
      $log.warn 'import error', e

  $scope.confirmReset = ->
    if confirm 'You will lose everything and restart the game. No reset-bonuses here. You sure?'
      # delete all storage, as advertised
      storage.removeItem session.id
      $scope.game.reset true
      $location.url '/'

  $scope.shorturl = ->
    feedback.createTinyurl($scope.form.export)
    .done (data, status, xhr) ->
      $scope.form.export = data.id
    .fail (data, status, error) ->
      $scope.imported.error = true

  $scope.clearThemeExtra = ->
    $scope.form.themeExtraSuccess = null
    $scope.form.themeExtraError = null
  $scope.themeExtra = (text) ->
    $scope.clearThemeExtra()
    try
      options.themeExtra text
      $scope.form.themeExtraSuccess = true
    catch e
      $log.error e
      $scope.form.themeExtraError = e?.message
      return
    #$log.debug 'themeExtra updates', themeExtraEl

  $scope.isDefaultMinSize = ->
    $scope.form.iframeMinSize.x == $scope.options.constructor.IFRAME_X_MIN and
      $scope.form.iframeMinSize.y == $scope.options.constructor.IFRAME_Y_MIN
  $scope.resetMinSize = ->
    $scope.options.iframeMinX $scope.form.iframeMinSize.x = $scope.options.constructor.IFRAME_X_MIN
    $scope.options.iframeMinY $scope.form.iframeMinSize.y = $scope.options.constructor.IFRAME_Y_MIN
