'use strict'
import {Decimal} from 'decimal.js'
import _ from 'lodash'

angular.module('swarmApp').factory 'Achievement', (util, $log, $rootScope, $filter) -> class Achievement
  constructor: (@game, @type) ->
    @name = @type.name
  _init: ->
    @game.session.state.achievements ?= {}
    @requires = _.map @type.requires, (require) =>
      require = _.clone require
      if require.unittype
        require.resource = require.unit = util.assert @game.unit require.unittype
      if require.upgradetype
        require.resource = require.upgrade = util.assert @game.upgrade require.upgradetype
      util.assert not (require.unit and require.upgrade), "achievement requirement can't have both unit and upgrade", @name
      return require
    util.assert @requires.length <= 1, 'multiple achievement requirements not yet supported', @name
    @visible = _.map @type.visible, (visible) =>
      visible = _.clone visible
      if visible.unittype
        visible.resource = visible.unit = util.assert @game.unit visible.unittype
      if visible.upgradetype
        visible.resource = visible.upgrade = util.assert @game.upgrade visible.upgradetype
      util.assert !!visible.unit isnt !!visible.upgrade, "achievement visiblity must have unit xor upgrade", @name
      return visible

  description: ->
    # "Why not angular templates?" I don't want to be forced to keep every
    # achievement description as a file, there's only one substitution needed,
    # and last time I tried to $compile spreadsheet data we leaked memory all
    # over the place. So, just do the one substitution.
    desc = @type.description
    if @type.requires.length > 0 and (@type.requires[0].unittype or @type.requires[0].upgradetype)
      # don't apply significant figures, achievement numbers are okay as-is
      desc = desc.replace '$REQUIRED', $filter('longnum')(@type.requires[0].val, undefined, {sigfigs: undefined})
    return desc

  isEarned: ->
    @game.session.state.achievements[@name]?

  earn: (elapsed=@game.elapsedStartMillis()) ->
    if not @isEarned()
      @game.withUnreifiedSave =>
        @game.session.state.achievements[@name] = elapsed
      $rootScope.$emit 'achieve', this

  earnedAtMillisElapsed: ->
    @game.session.state.achievements[@name]

  earnedAtMoment: ->
    if not @isEarned()?
      return undefined
    ret = moment @game.session.state.date.started
    ret.add @game.session.state.achievements[@name], 'ms'
    return ret

  pointsEarned: ->
    if @isEarned() then @type.points else 0

  # invisible achievements are masked with ???s. TODO support truly hidden achievements
  isMasked: -> not @isUnmasked()
  isUnmasked: ->
    # special case: no requirements specified == forever-masked
    # (if you'd like always-visible, a visibility of meat:0 works)
    if @visible.length == 0
      return false
    for visible in @visible
      if visible.resource.count().lessThan(visible.val)
        return false
    return true

  hasProgress: ->
    for req in @requires
      if req.resource?
        return true
    return false
  progressMax: ->
    if @hasProgress()? and @requires[0].val?
      return new Decimal @requires[0].val
  progressVal: ->
    req = @requires[0]
    if req.upgrade?
      return req.upgrade.count()
    if req.unit?
      if req.unit.unittype.unbuyable
        return req.unit.count()
      return new Decimal req.unit.statistics().twinnum ? 0
    return undefined
  progressPercent: ->
    if @hasProgress()?
      return @progressVal().dividedBy(@progressMax())
  progressOrder: ->
    if @isEarned()
      return 2
    if @isMasked()
      return -2
    if @hasProgress() and @progressMax() > 0
      return @progressPercent().toNumber()
    return -1

angular.module('swarmApp').factory 'AchievementTypes', (spreadsheetUtil, util, $log) -> class AchievementTypes
  constructor: ->
    @list = []
    @byName = {}

  register: (achievement) ->
    @list.push achievement
    @byName[achievement.name] = achievement

  pointsPossible: ->
    return util.sum _.map @list, (a) -> a.points

  @parseSpreadsheet: (data, unittypes, upgradetypes) ->
    rows = spreadsheetUtil.parseRows {name:['requires', 'visible']}, data.data.achievements.elements
    ret = new AchievementTypes()
    for row in rows
      ret.register row
    for row in ret.list
      spreadsheetUtil.resolveList row.requires, 'unittype', unittypes.byName, {required:false}
      spreadsheetUtil.resolveList row.requires, 'upgradetype', upgradetypes.byName, {required:false}
      spreadsheetUtil.resolveList row.visible, 'unittype', unittypes.byName, {required:false}
      spreadsheetUtil.resolveList row.visible, 'upgradetype', upgradetypes.byName, {required:false}
      util.assert row.points >= 0, 'achievement must have points', row.name, row
      util.assert _.isNumber(row.points), 'achievement points must be number', row.name, row
    return ret

angular.module('swarmApp').factory 'AchievementsListener', (util, $log) -> class AchievementsListener
  constructor: (@game, @scope) ->
    @_listen @scope

  achieveUnit: (unitname, rawcount=false) ->
    # actually checks all units
    for achieve in @game.achievementlist()
      for require in achieve.requires
        # unit count achievement
        if not require.event and require.unit and require.val
          if rawcount
            # exceptional case, count all units, ignoring statistics
            count = require.unit.count()
          else
            # usually we want to ignore generators, so use statistics-count
            # statistics are added before achievement-check, fortunately
            count = require.unit.statistics().twinnum ? 0
            count = new Decimal count
          $log.debug 'achievement check: unitcount after command', require.unit.name, count+'', count? && count >= require.val
          if count? && count.greaterThanOrEqualTo(require.val)
            $log.debug 'earned', achieve.name, achieve
            # requirements are 'or'ed
            achieve.earn()
  achieveUpgrade: (upgradename) ->
    # actually checks all upgrades
    for achieve in @game.achievementlist()
      for require in achieve.requires
        if not require.event and require.upgrade and require.val
          # no upgrade-generators, so count() is safe
          count = require.upgrade.count()
          $log.debug 'achievement check: upgradecount after command', require.upgrade.name, count, count? && count >= require.val
          if count? && count.greaterThanOrEqualTo(require.val)
            $log.debug 'earned', achieve.name, achieve
            # requirements are 'or'ed
            achieve.earn()

  _listen: (@scope) ->
    for achieve in @game.achievementlist() then do (achieve) =>
      for require in achieve.requires
        if require.event and not require.unit then do (require) =>
          # trigger event once achievement
          if require.val
            require.val = JSON.parse require.val
            $log.debug 'parse event-achievement json', require.event, require.val
          cancelListen = @scope.$on require.event, (event, param) =>
            $log.debug 'achieve listen', require.event, param, require.val
            if require.val
              # very simple equality validation
              validparam = _.pick param, _.keys require.val
              valid = _.isEqual validparam, require.val
              $log.debug 'validate', require.event, require.val, validparam, valid
              if not valid
                return
            achieve.earn()
            # TODO rebuild this on reset
            #cancelListen()

    @scope.$on 'command', (event, cmd) =>
      $log.debug 'checking achievements for command', cmd
      if cmd.unitname?
        @achieveUnit cmd.unitname
      if cmd.upgradename?
        @achieveUpgrade cmd.upgradename
      if cmd.name == 'ascension'
        $log.debug 'ascending!', @game.unit('ascension').count()
        @achieveUnit 'ascension', true

angular.module('swarmApp').factory 'achievementslistener', (AchievementsListener, game, $rootScope) ->
  new AchievementsListener game, $rootScope

###*
 # @ngdoc service
 # @name swarmApp.achievements
 # @description
 # # achievements
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'achievements', (AchievementTypes, unittypes, upgradetypes, spreadsheet) ->
  AchievementTypes.parseSpreadsheet spreadsheet, unittypes, upgradetypes
