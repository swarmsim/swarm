/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
// NOPE, this sets some globals with `var` and has to be imported in index.html
// import 'playfab-web-sdk/src/PlayFab/PlayFabClientApi'

import * as persist from '@bower_components/swarm-persist';

// console.log('playfab', {PlayFab: window.PlayFab, PlayFabClientSDK: window.PlayFabClientSDK})

// https://github.com/PlayFab/JavaScriptSDK

angular.module('swarmApp').factory('playfabCredentialStore', function($log) { let PlayfabCredentialStore;
return new (PlayfabCredentialStore = class PlayfabCredentialStore {
  constructor(key) {
    if (key == null) { key = "playfabCredentials"; }
    this.key = key;
  }
  write(email, password) {
    // Storing a password this way is terribly insecure.
    // But... playfab doesn't have its own remember-me option, the
    // convenience is more important than the security for my little game,
    // other games/sites do this, and I can't be bothered to set up
    // something with playfab customids right now.
    return window.localStorage.setItem(this.key, JSON.stringify({
      email,
      //password: password
      // This is still insecure, but if I'm going to take shortcuts here,
      // the least we can do is obfuscate it slightly
      password: window.btoa(password)
    })
    );
  }
  read() {
    let ret = window.localStorage.getItem(this.key);
    if (ret) {
      try {
        ret = JSON.parse(ret);
        ret.password = window.atob(ret.password);
        return ret;
      } catch (e) {
        $log.warning(e);
        return undefined;
      }
    }
  }
  clear() {
    return window.localStorage.removeItem(this.key);
  }
});
 });

// https://developer.playfab.com/en-us/F810/limits
// Playfab has a size limit of 10k bytes per key. Swarmsim's passed that before. We can update 10 keys per push for a limit of 100k, which is enough.
angular.module('swarmApp').factory('playfabStateChunker', () => persist.chunker);

/**
 * @ngdoc service
 * @name swarmApp.playfab
 * @description
 * # playfab
 * Service in the swarmApp.
*/
angular.module('swarmApp').factory('Playfab', function($q, $log, playfabCredentialStore, playfabStateChunker) { let Playfab;
return Playfab = class Playfab {
  constructor() {
    this._call = this._call.bind(this);
  }
  isAuthed() { return !!this.auth; }
  logout() {
    this.auth = null;
    this.authRequest = null;
    return playfabCredentialStore.clear();
  }

  login(email, password, remember) { return this.authRequest = $q((resolve, reject) => {
    return window.PlayFabClientSDK.LoginWithEmailAddress({
      Email: email,
      Password: password,
      InfoRequestParameters: {
        GetUserAccountInfo: true,
        GetUserData: true
      }
    },
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('login success', response);
          if (remember) {
            playfabCredentialStore.write(email, password);
          }
          this.auth = {
            raw: response.data,
            rawType: 'login',
            email
          };
          this._loadUserData(response.data.InfoResultPayload.UserData);
          return resolve(response.data);
        } else {
          return reject(error);
        }
    });
  }); }

  waitForAuth() {
    if (!this.authRequest) {
      this.autologin();
    }
    return this.authRequest;
  }
  autologin() {
    const creds = playfabCredentialStore.read();
    if ((creds != null ? creds.email : undefined) && (creds != null ? creds.password : undefined)) {
      $log.debug('found playfab autologin creds');
      return this.login(creds.email, creds.password, false);
    } else {
      $log.debug('playfab autologin failed, no creds stored');
      return this.authRequest = $q((resolve, reject) => reject());
    }
  }

  // https://api.playfab.com/Documentation/Client/method/LoginWithKongregate
  kongregateLogin(userId, authToken) { return this.authRequest = $q((resolve, reject) => {
    return window.PlayFabClientSDK.LoginWithKongregate({
      KongregateId: userId,
      AuthTicket: authToken,
      CreateAccount: true,
      InfoRequestParameters: {
        GetUserAccountInfo: true,
        GetUserData: true
      }
    },
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('login success', response);
          this.auth = {
            raw: response.data,
            rawType: 'login'
          };
          this._loadUserData(response.data.InfoResultPayload.UserData);
          return resolve(response.data);
        } else {
          return reject(error);
        }
    });
  }); }

  signup(email, password) { return this.authRequest($q((resolve, reject) => {
    return window.PlayFabClientSDK.RegisterPlayFabUser({
      RequireBothUsernameAndEmail: false, // email's enough, no need for usernames
      Email: email,
      Password: password
    },
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('signup success', response);
          this.auth = {
            raw: response.data,
            rawType: 'signup',
            email,
            state: null,
            lastUpdated: new Date().getTime()
          };
          return resolve(response.data);
        } else {
          return reject(error);
        }
    });
  })
  ); }

  forgot(email) { return $q((resolve, reject) => {
    return window.PlayFabClientSDK.SendAccountRecoveryEmail({
      TitleId: window.PlayFab.settings.titleId,
      Email: email
    },
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('forgot success', response);
          return resolve(response.data);
        } else {
          return reject(error);
        }
    });
  }); }

  push(state) { return $q((resolve, reject) => {
    // limit is 10000 bytes per key. We can chunk it into 10 keys per request though.
    // TODO: chunking.
    // https://developer.playfab.com/en-us/F810/limits
    return window.PlayFabClientSDK.UpdateUserData(
      {Data: playfabStateChunker.encode(state)},
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('push success', response);
          this.auth.state = state;
          this.auth.lastUpdated = new Date().getTime();
          return resolve(this.auth);
        } else {
          return reject(error);
        }
    });
  }); }

  clear() { return $q((resolve, reject) => {
    return window.PlayFabClientSDK.UpdateUserData(
      {KeysToRemove: playfabStateChunker.keys()},
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('clear success', response);
          this.auth.state = null;
          this.auth.lastUpdated = new Date().getTime();
          return resolve(this.auth);
        } else {
          return reject(error);
        }
    });
  }); }

  _loadUserData(data) {
    this.auth.state = playfabStateChunker.decode(data);
    return this.auth.lastUpdated = new Date(data.state != null ? data.state.LastUpdated : undefined).getTime();
  }
  fetch() { return $q((resolve, reject) => {
    return window.PlayFabClientSDK.GetUserData({},
      (response, error) => {
        if (response && (response.code === 200)) {
          console.log('fetch success', response);
          this._loadUserData(response.data.Data);
          return resolve(this.auth);
        } else {
          return reject(error);
        }
    });
  }); }

  // "why isn't this used above?" it was added later. The above would be better if this were used, just haven't bothered yet.
  _call(name, params) {
    if (params == null) { params = {}; }
    const errorData = {name, params};
    const p = $q((resolve, reject) => {
      return this.waitForAuth().then(
        () => {
          return window.PlayFabClientSDK[name](params, res => {
            errorData.result = res;
            if (res.status !== 'OK') {
              errorData.message = `PlayFabClientAPI.${name} returned status ${res.status}`;
              return reject(errorData);
            }
            $log.debug(`PlayFabClientAPI.${name}`, res.status, res);
            return resolve(res);
          });
        },
        error => {
          errorData.message = error;
          return reject(errorData);
      });
    });
    return p;
  }
  getTitleNews() { return this._call('GetTitleNews'); }
};
 });

angular.module('swarmApp').factory('playfab', function(Playfab, env) {
  window.PlayFab.settings.titleId = env.playfabTitleId;
  return new Playfab();
});

angular.module('swarmApp').factory('playfabCall', function($q, $log) {});

