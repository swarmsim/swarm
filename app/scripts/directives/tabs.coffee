'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tabs
 # @description
 # # tabs
###
angular.module('swarmApp').directive 'tabs', (game, util, options, version) ->
  templateUrl: 'views/tabs.html'
  scope:
    cur: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.tabs = game.tabs
    scope.options = options
    scope.filterVisible = (tab) -> tab.isVisible()

    scope.feedbackUrl = ->
      param = "#{version}|#{window?.navigator?.userAgent}|#{game.session.exportSave()}"
      "https://docs.google.com/forms/d/1yH2oNcjUJiggxQhoP3pwijWU-nZkT-hJsqOR-5_cwrI/viewform?entry.436676437=#{encodeURIComponent param}"

    util.animateController scope, game:game, options:options
