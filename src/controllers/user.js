/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

angular.module('swarmApp').factory('userResource', function($log, $location, $routeParams, userApi, loginApi) { let UserResource;
return new (UserResource = class UserResource {
  constructor() {
    // TODO htmlify descriptions
    this.leagues = {
      list: [{
        name: 'open',
        label: 'Open League',
        isPlayable: true,
        desc: 'The default league. Never ends.'
      },{
        name: 'void',
        label: 'Null League (Unplayable)',
        isPlayable: false,
        desc: 'This character is no longer playable.'
      },{
        name: 'temp1',
        label: 'Test Temporary League',
        isPlayable: true,
        desc: 'x3 larva production or something. I dunno, TBD before the publictest release. Characters join open league after a month or so.'
      }]
    };
    this.leagues.byName = _.keyBy(this.leagues.list, 'name');
    // because I can't get ng-repeat filters working
    this.leagues.playableList = _.filter(this.leagues.list, 'isPlayable');
  }
    
  init($scope) {
    let userId;
    $scope.leagues = this.leagues;
    $scope._loginApi = loginApi; // for watch
    if ((($scope.userSlug=(userId=$routeParams.user)) == null)) {
      $location.url('/');
    }
    ($scope.refreshUser = function() {
      // special case: /user/me gets the current user
      if (userId === 'me') {
        $scope.user = loginApi.user;
        $log.debug('userload hook', $scope.user);
        return $scope.$watch('_loginApi.user', (user, olduser) => {
          $scope.user = user;
          return $log.debug('user loaded', $scope.user);
        });
      } else {
        return $scope.user = userApi.get({id:userId});
      }
    })();
    return $scope.$watchCollection('[user.id, _loginApi.user]', () => {
      return $scope.isSelf = (($scope.user != null ? $scope.user.id : undefined) != null) && ($scope.user.id === (loginApi.user != null ? loginApi.user.id : undefined));
    });
  }
});
 });

/**
 * @ngdoc function
 * @name swarmApp.controller:UserCtrl
 * @description
 * # UserCtrl
 * Controller of the swarmApp
*/
angular.module('swarmApp').controller('UserCtrl', function($scope, $log, userResource, $routeParams, characterApi) {
  $log.debug('userctrl', $routeParams);
  userResource.init($scope);

  $scope.$watch('user.characters', chars => $scope.characters = _.map(chars, char => _.extend({}, char, {
    _raw: char,
    league: $scope.leagues.byName[char.league],
    updatedAt: moment(char.updatedAt),
    createdAt: moment(char.createdAt)
  }
  )));
  $scope.onDelete = function(character) {
    if (character.name === window.prompt("Are you sure? Type this character's name to confirm deletion.")) {
      return characterApi.update({id:character.id},
        {deleted: true},
        () => $scope.refreshUser());
    }
  };
  return $scope.onDupe = function(character) {
    $log.debug('duplicating character', character);
    return characterApi.save(_.omit(character._raw, 'id', 'createdAt', 'updatedAt'),
      function() {
        $log.debug('duplicated character', character);
        return $scope.refreshUser();
    });
  };
});

angular.module('swarmApp').controller('NewCharacterCtrl', function($scope, $log, userResource, characterApi, $location) {
  userResource.init($scope);
  $scope.form = {
    name: 'Unnamed Swarm',
    league: 'open'
  };

  return $scope.onSubmit = () => characterApi.save({
    name: $scope.form.name,
    league: $scope.form.league,
    source: 'newCharForm',
    state: {},
    user: $scope.user.id
  },
    character => $location.url(`/c/${character.id}`));
});
