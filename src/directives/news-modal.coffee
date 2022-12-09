'use strict'
import * as views from '../views'

###*
 # @ngdoc directive
 # @name swarmApp.directive:newsModal
 # @description
 # # newsModal
###
angular.module('swarmApp').directive 'newsModal', (game, playfab, $location, $sce) ->
  restrict: 'EA'
  template: views.newsModal
  link: ($scope, element, attrs) ->
    $scope.state = 'loading'
    threshold = moment($location.search().lastnews or game.session.state.date.lastNews or game.session.state.date.started)
    #console.log threshold, game.session.state.date

    modalElem = $(element).children()
    modalElem.on 'hidden.bs.modal', (e) =>
      game.session.state.date.lastNews = new Date()
      game.save()
    $scope.close = =>
      modalElem.modal 'hide'

    parseBody = (item) =>
      try
        return JSON.parse item.Body
      catch e
        return {
          # this comes from Playfab's UI. Trusting HTML outside the app is dangerous, but I trust playfab staff not to mess with my game.
          trustedHtml: $sce.trustAsHtml(item.Body)
        }
    playfab.getTitleNews().then(
      (res) =>
        $scope.state = 'success'
        news = res.data.News.map (item) =>
          return Object.assign parseBody(item),
            date: new moment(item.Timestamp)
            title: item.Title
            id: item.NewsId
        $scope.news = news.filter (item) => item.date.isAfter threshold
        if !!$scope.news.length
          modalElem.modal({show: true})
        #console.log 'success!', $scope.news
      (error) =>
        $scope.state = 'error'
        $scope.error = error
    )
