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
angular.module('swarmApp').directive 'unit', ($log, game, commands, options, util, $location, parseNumber, hotkeys) ->
  templateUrl: 'views/directive-unit.html'
  restrict: 'E'
  scope:
    cur: '='
  link: (scope, element, attrs) ->
    scope.game = game
    scope.commands = commands
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

    scope.form = {buyCount:''}
    search = $location.search()
    if search.num?
      scope.form.buyCount = search.num
    else if search.twinnum?
      # legacy format - our code doesn't use `?twinnum=n` anymore, but it used to. some users might still use it.
      scope.form.buyCount = "=#{search.twinnum}"

    _buyCount = new Decimal(1)
    scope.buyCount = ->
      parsed = parseNumber(scope.form.buyCount or '1', scope.cur) ? new Decimal(1)
      # caching required for angular
      if not parsed.equals _buyCount
        _buyCount = parsed
      return _buyCount

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

    scope.unitCostAsPercent = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.count()
      if count.lessThanOrEqualTo 0
        return MAX
      num = Decimal.max 1, unit.maxCostMet()
      Decimal.min MAX, cost.val.times(num).dividedBy(count)
    
    scope.unitCostAsPercentOfVelocity = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.velocity()
      if count.lessThanOrEqualTo 0
        return MAX
      Decimal.min MAX, cost.val.times(unit.maxCostMetOfVelocity()).dividedBy(count)

    scope.description = (resource, desc=resource.descriptionFn) ->
      # this makes descriptions a potential xss vector. careful to only use numbers.
      desc scope
