'use strict'

angular.module('swarmApp').directive 'focusInput', ($timeout, hotkeys) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    focus = (event) ->
      element[0].focus()
      event.preventDefault()
    # autofocus
    # $timeout focus, 0
    # hotkey focus
    hotkeys.bindTo(scope).add
      combo: '/'
      description: 'Focus buy-unit input field'
      callback: focus

###*
 # @ngdoc directive
 # @name swarmApp.directive:unit
 # @description
 # # unit
###
angular.module('swarmApp').directive 'unit', ($log, game, options, util, $location, hotkeys) ->
  templateUrl: 'views/directive-unit.html'
  restrict: 'E'
  scope:
    cur: '='
  link: (scope, element, attrs) ->
    scope.game = game
    scope.options = options

    hk = hotkeys.bindTo(scope)
    if scope.cur.prev?
      hk.add
        combo: ['down', 'left']
        description: 'Select '+scope.cur.prev.type.plural
        callback: (event) ->
          $location.path '/unit/'+scope.cur.prev.unittype.slug
          event.preventDefault()
    if scope.cur.next?
      hk.add
        combo: ['up', 'right']
        description: 'Select '+scope.cur.next.type.plural
        callback: (event) ->
          $location.path '/unit/'+scope.cur.next.unittype.slug
          event.preventDefault()

    formatDuration = (estimate) ->
    scope.estimateUpgradeSecs = (upgrade) ->
      estimate = upgrade.estimateSecsUntilBuyable()
      val = estimate.val.toNumber()
      if isFinite val
        secs = moment.duration(val, 'seconds')
        #add nonexact annotation for use by filter
        secs.nonexact = not (estimate.unit?.isEstimateExact?() ? true)
        return secs
      # infinite estimate, but moment doesn't like infinite durations.
      return Infinity

    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

    scope.watched = {}
    for upgrade in scope.cur.upgrades.byClass.upgrade ? []
      scope.watched[upgrade.name] = upgrade.watchedAt()
    for upgrade in scope.cur.upgrades.byClass.ability ? []
      scope.watched[upgrade.name] = not upgrade.isManuallyHidden()
    scope.updateWatched = (upgrade) ->
      upgrade.watch scope.watched[upgrade.name]
    scope.updateWatchedAbility = (upgrade) ->
      upgrade.watch if scope.watched[upgrade.name] then 0 else -1
