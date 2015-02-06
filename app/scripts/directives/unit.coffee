'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:unit
 # @description
 # # unit
###
angular.module('swarmApp').directive 'unit', ($log, game, commands, options, util, $location, $sce) ->
  templateUrl: 'views/directive-unit.html'
  restrict: 'E'
  scope:
    cur: '='
  link: (scope, element, attrs) ->
    scope.game = game
    scope.commands = commands
    scope.options = options

    # not good enough - this runs only once, we want to be viewNewUpgrades()'ing constantly while the unit is in view
    #scope.cur.viewNewUpgrades()

    scope.estimtateUpgradeSecs = (upgrade) ->
      estimate = upgrade.estimateSecs()
      #util.utcdoy 1000 * secs
      if isFinite estimate.val
        nonlinear = if not (estimate.unit?.isVelocityConstant?() ? true) then 'less than ' else ''
        secs = moment.duration(estimate.val, 'seconds').humanize()
        if /\ years$/.test secs
          secs = 'a long time'
          nonlinear = ''
        return ", #{nonlinear}#{secs}"
      return ""

    parseNum = (num) ->
      if num?
        try
          num = new Decimal num
        catch e
          return undefined
        if num.isFinite() and not num.isNaN()
          return num
      return undefined
    _buyN = do ->
      ret = Decimal.ONE
      if (search = $location.search())?
        if (val = parseNum search.num)?
          ret = val.ceil()
        else if (val = parseNum search.twinnum)?
          ret = val.dividedBy(scope.cur.twinMult()).ceil()
      $log.debug 'buyN initial value', ret.toJSON()
      return ret
    scope.initBuyN = =>
      # I know you're not supposed to reference dom from angular controllers; I'd rather use ng-model too.
      # Angular's (quite reasonably) casting input with type="number" to a JS number, but I need a string 
      # for decimal.js and can't turn that off. I want type="number" on the input (instead of, say,
      # type="text" with extra validation) for the number-spinner on desktop and number-keyboard on mobile.
      inputElement = element.find 'input[name="buyN"]'
      scope.updateBuyN = ->
        val = inputElement.val()
        if not val
          val = 1
        _buyN = Decimal.max 1, val
        $log.debug 'updateBuyN', inputElement.val(), _buyN.toJSON()
      inputElement.change scope.updateBuyN
      return undefined
    scope.buyN = ->
      # careful here, angular freaks out if you return different objects when the value hasn't changed
      return _buyN
    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

    scope.viewNewUpgrades = ->
      scope.cur.viewNewUpgrades()
      return undefined # important - the result is displayed

    scope.unitCostAsPercent = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.count()
      if count.lessThanOrEqualTo 0
        return MAX
      num = Decimal.max 1, unit.maxCostMet()
      Decimal.min MAX, cost.val.times(num).dividedBy(count)

    scope.description = (resource, desc=resource.descriptionFn) ->
      # this makes descriptions a potential xss vector. careful to only use numbers.
      desc scope

    # TODO why isn't this inherited automatically?
    scope.floor ?= scope.$root.floor
