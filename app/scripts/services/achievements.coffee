'use strict'

angular.module('swarmApp').factory 'Achievement', (util, $log) -> class Achievement
  constructor: (@game, @type) ->
    @name = @type.name
  _init: ->
    @requires = _.map @type.requires, (require) =>
      require = _.clone require
      require.unit = util.assert @game.unit require.unittype
      return require

  isEarned: ->
    @game.session.achievements[@name]?

  earn: (elapsed=@game.elapsedStartMillis()) ->
    if @isEarned()
      return
    @game.session.achievements[@name] = elapsed

  earnedAtMillisElapsed: ->
    @game.session.achievements[@name]

  pointsEarned: ->
    if @isEarned() then @type.points else 0

angular.module('swarmApp').factory 'AchievementTypes', (spreadsheetUtil, util, $log) -> class AchievementTypes
  constructor: ->
    @list = []
    @byName = {}

  register: (achievement) ->
    @list.push achievement
    @byName[achievement.name] = achievement

  @parseSpreadsheet: (data, unittypes) ->
    rows = spreadsheetUtil.parseRows {name:['requires']}, data.data.achievements.elements
    ret = new AchievementTypes()
    for row in rows
      ret.register row
    for row in ret.list
      spreadsheetUtil.resolveList row.requires, 'unittype', unittypes.byName
      util.assert row.points > 0, 'achievement must have points', row.name, row
      util.assert _.isNumber(row.points), 'achievement points must be number', row.name, row
    return ret

###*
 # @ngdoc service
 # @name swarmApp.achievements
 # @description
 # # achievements
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'achievements', (AchievementTypes, unittypes, spreadsheet) ->
  AchievementTypes.parseSpreadsheet spreadsheet, unittypes
