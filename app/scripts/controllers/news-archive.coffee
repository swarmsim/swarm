'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:NewsArchiveCtrl
 # @description
 # # NewsArchiveCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'NewsArchiveCtrl', ($scope, playfab) ->
  $scope.state = 'loading'
  parseBody = (item) =>
    try
      return JSON.parse item.Body
    catch e
      return {text: item.Body}
  playfab.getTitleNews().then(
    (res) =>
      $scope.state = 'success'
      $scope.news = res.data.News.map (item) =>
        return Object.assign parseBody(item),
          date: new moment(item.Timestamp)
          title: item.Title
          id: item.NewsId
      console.log 'success', $scope.news
    (error) =>
      $scope.state = 'error'
      $scope.error = error
  )
