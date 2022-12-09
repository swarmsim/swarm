/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

/**
 * @ngdoc service
 * @name swarmApp.userApi
 * @description
 * # userApi
 * Factory in the swarmApp.
*/
angular.module('swarmApp').factory('userApi', function($resource, env) {
  if (!env.isServerBackendEnabled) {
    return $resource("/DISABLED/user/:id");
  }
  return $resource(`${env.saveServerUrl}/user/:id`);
});

angular.module('swarmApp').factory('characterApi', function($resource, env) {
  if (!env.isServerBackendEnabled) {
    return $resource("/DISABLED/character/:id");
  }
  return $resource(`${env.saveServerUrl}/character/:id`);
});

angular.module('swarmApp').factory('commandApi', function($resource, env) {
  if (!env.isServerBackendEnabled) {
    return $resource("/DISABLED/command/:id");
  }
  return $resource(`${env.saveServerUrl}/command/:id`);
});

// shortcut
angular.module('swarmApp').factory('user', loginApi => () => loginApi.user);

angular.module('swarmApp').config(function($httpProvider) {
  // http://stackoverflow.com/questions/22100084/angularjs-withcredentials-not-sending?rq=1
  $httpProvider.defaults.useXDomain = true;
  return $httpProvider.defaults.withCredentials = true;
});

angular.module('swarmApp').factory('loginApi', function(loginApiEnabled, env) {
  if (env.isServerBackendEnabled) {
    return loginApiEnabled;
  }
  const ret = {};
  const noop = {logout:true,saveCommand:true,whoami:true,maybeConnectLegacyCharacter:true};
  for (var method in loginApiEnabled) {
    var fn = loginApiEnabled[method];
    if (noop[method]) {
      ret[method] = function() {};
    } else {
      ret[method] = function() {
        throw new Error('login backend is disabled');
      };
    }
  }
  return ret;
});

angular.module('swarmApp').factory('loginApiEnabled', function($http, env, util, $log, session, characterApi, isKongregate, commandApi) { let LoginApi;
return new ((LoginApi = (function() {
  LoginApi = class LoginApi {
    static initClass() {
  
      this.LOGIN_TAILS = {
        kongregate: '/callback',
        guestuser: '/callback'
      };
    }
    constructor() {
      this.characters = {};
      if (env.isServerBackendEnabled) {
        this.user = this.whoami().then(
          () => {
            // connect legacy character upon page reload
            this.maybeConnectLegacyCharacter();
            //if env.isServerFrontendEnabled
            //  # TODO import most recently used character from server. need to know when connectLegacyCharacter above is done, though
            return $log.debug('user already logged in', this.user);
          },
          () => {
            // not logged in.
            // TODO guest login, with some caveats:
            // * no guest login if isKongregate(), kong might still be loading
            //   * kong has guest users too, though! what if their guest isn't logged in?
            // * yes guest login if there's a saved character, which proves this isn't a new visitor - it's a legacy character.
            //   * import the legacy character right away, and don't create a new character for the guest.
            // * no guest login YET if there's no saved character - this is a fresh visitor, and they might already have an account they're about to log in to.
            //   * guest login comes later, once they take an action like buying a drone.
            //     * how to handle creating their character, though? new characters shouldn't start as legacy imports, and we can't just allow infinitely backdated character creation!
            // OR, maybe just guest-login now in every case, and delete the guest later if it's not needed? creating an empty user/character in the db isn't very expensive. pollutes the db though. eh... do it anyway.
            if (!isKongregate()) {
              return this.login('guestuser')
              .then(
                () => {
                  $log.debug('created guest user');
                  return this.maybeConnectLegacyCharacter();
                },
                () => {
                  return $log.debug('failed to create guest user');
              });
            }
        });
      }
    }
    hasUser() {
      return (this.user.id != null);
    }

    whoami() {
      if (!env.isServerBackendEnabled) {
        return;
      }
      return $http.get(`${env.saveServerUrl}/whoami`)
      .then(
        (data, status, xhr) => {
          return this.user = data;
        },
        (data, status, xhr) => {
          return this.user = {};
      });
    }
    login(strategy, credentials) {
      if (credentials == null) { credentials = {}; }
      const tail = this.constructor.LOGIN_TAILS[strategy] != null ? this.constructor.LOGIN_TAILS[strategy] : '';
      if (!env.saveServerUrl) {
        $log.error("env.saveServerUrl is blank, expect all swarmapi calls to fail. I hope this isn't the production environment!");
      }
      return $http.post(`${env.saveServerUrl}/auth/${strategy}${tail}`, credentials, {withCredentials: true})
      .then(
        (data, status, xhr) => {
          this.user = data.user;
          // connect legacy character upon login
          return this.maybeConnectLegacyCharacter();
      });
    }
 
    logout() {
      if (!env.isServerBackendEnabled) {
        return;
      }
      return $http.get(`${env.saveServerUrl}/logout`, {}, {withCredentials: true})
      .then(
        (data, status, xhr) => {
          return this.whoami();
      });
    }

    maybeConnectLegacyCharacter() {
      // TODO: might import from multiple devices. import if there's any chance we'd overwrite the only save!
      // TODO should we freak out if the character's already connected to a different user?
      if (!env.isServerBackendEnabled) {
        return;
      }
      if ((this.user != null) && (session.state.idOnServer == null)) {
        let character;
        $log.debug('connectLegacyCharacter found a legacy character, connecting...');
        const state = session.exportJson();
        return character = characterApi.save({
          user: this.user.id,
          name: 'swarm',
          source: 'connectLegacy',
          state: session.exportJson()
        },
          (data, status, xhr) => {
            session.state.idOnServer = character.id;
            this.characters[character.id] = character;
            session.save();
            return $log.debug('connectLegacyCharacter connected!', session.state.serverId);
          },
          (data, status, xhr) => {
            return $log.warn('connectLegacyCharacter failed!', data, status, xhr);
        });
      }
    }

    saveCommand(commandBody) {
      let command;
      if (!env.isServerBackendEnabled) {
        return;
      }
      // Just save the character for now. Later we'll save the command, but just get the traffic flowing to the server to see if we'll scale.
      if ((session.state.idOnServer == null)) {
        $log.debug('server saveCommand quitting because character has no id. trying connectlegacycharacter.', commandBody);
        return this.maybeConnectLegacyCharacter();
      }
        // TODO save the first command; focus on server character more
      const character = session.exportJson();
      commandBody = _.omit(commandBody, ['unit', 'upgrade']);
      $log.debug('server saveCommand start', command);
      return command = commandApi.save({
        character: session.state.idOnServer,
        body: commandBody,
        state: character
      },
        (data, status, xhr) => {
          return $log.debug('server saveCommand success', command);
        },
        (data, status, xhr) => {
          $log.warn('server saveCommand failed!', data, status, xhr);
          // TODO remove this when truly depending on server characters! this is v1.1 test code.
          if (400 <= data.status && data.status < 500) {
            $log.warn('server saveCommand bad request. trying to recreate character on server.', command);
            delete session.state.idOnServer;
            return this.maybeConnectLegacyCharacter();
          }
      });
    }
  };
  LoginApi.initClass();
  return LoginApi;
})()));
 });
