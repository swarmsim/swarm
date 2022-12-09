/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:newsModal
 * @description
 * # newsModal
*/
angular.module('swarmApp').directive('newsModal', (game, playfab, $location, $sce) => ({
  restrict: 'EA',
  template: views.newsModal,

  link($scope, element, attrs) {
    $scope.state = 'loading';
    const threshold = moment($location.search().lastnews || game.session.state.date.lastNews || game.session.state.date.started);
    //console.log threshold, game.session.state.date

    const modalElem = $(element).children();
    modalElem.on('hidden.bs.modal', e => {
      game.session.state.date.lastNews = new Date();
      return game.save();
    });
    $scope.close = () => {
      return modalElem.modal('hide');
    };

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
        const news = res.data.News.map(item => {
          return Object.assign(parseBody(item), {
            date: new moment(item.Timestamp),
            title: item.Title,
            id: item.NewsId
          }
          );
        });
        $scope.news = news.filter(item => item.date.isAfter(threshold));
        if (!!$scope.news.length) {
          return modalElem.modal({show: true});
        }
      },
        //console.log 'success!', $scope.news
      error => {
        $scope.state = 'error';
        return $scope.error = error;
    });
  }
}));
