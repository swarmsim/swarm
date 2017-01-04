'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:playfab
 # @description
 # # playfab
###
angular.module('swarmApp').directive 'playfaboptions', (playfab, options, session, game) ->
  templateUrl: 'views/playfab/options.html'
  restrict: 'EA'
  link: (scope, element, attrs) ->
    scope.form =
      autopush: options.autopush()
    scope.name = playfab.auth.email
    #scope.fetched = {state: 'abcde', lastUpdated: moment(999)}
    handleFetched = (auth) =>
      scope.fetched =
        state: auth.state
        lastUpdated: moment(auth.lastUpdated)
    handleFetched(playfab.auth)

    scope.setAutopush = (val) -> options.autopush(val)
    scope.push = -> playfab.push(session.exportSave()).then(handleFetched)
    scope.fetch = -> playfab.fetch().then(handleFetched)
    scope.pull = -> playfab.fetch().then(
      (auth) =>
        handleFetched(auth)
        game.importSave(auth.state)
    )
    scope.clear = -> playfab.clear().then(handleFetched)
    scope.logout = -> playfab.logout()
    scope.autopushError = ->
