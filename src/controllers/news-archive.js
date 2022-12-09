/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc function
 * @name swarmApp.controller:NewsArchiveCtrl
 * @description
 * # NewsArchiveCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('NewsArchiveCtrl', function($scope, playfab, $sce) {
  $scope.state = 'loading';
  const parseBody = item => {
    try {
      return JSON.parse(item.Body);
    } catch (e) {
      return {
        // this comes from Playfab's UI. Trusting HTML outside the app is dangerous, but I trust playfab staff not to mess with my game.
        trustedHtml: $sce.trustAsHtml(item.Body)
      };
    }
  };
  return playfab.getTitleNews().then(
    res => {
      $scope.state = 'success';
      return $scope.news = res.data.News.map(item => {
        return Object.assign(parseBody(item), {
          date: new moment(item.Timestamp),
          title: item.Title,
          id: item.NewsId
        }
        );
      });
    },
    error => {
      $scope.state = 'error';
      return $scope.error = error;
  });
});
