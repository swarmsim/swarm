/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';

/**
 * @ngdoc service
 * @name swarmApp.Kongregate
 * @description
 * # Kongregate
 * Service in the swarmApp.
 *
 * http://developers.kongregate.com/docs/api-overview/client-api
*/
angular.module('swarmApp').factory('isKongregate', () => () => // use the non-# querystring to avoid losing it when the url changes. $location.search() won't work.
// a simple string-contains is hacky, but good enough as long as we're not using the querystring for anything else.
_.includes(window.location.search, 'kongregate'));
    // alternatives:
    // - #-querystring is overwritten on reload.
    // - url is hard to test, and flaky with proxies.
    // - separate deployment? functional, but ugly maintenance.
    // - when-framed-assume-kongregate? could work...
    // - hard-querystring (/?kongregate#/tab/meat) seems to work well! can't figure out how to get out of it in 30sec.

angular.module('swarmApp').factory('Kongregate', function(isKongregate, $log, $location, game, $rootScope, $interval, options, $q, loginApi, env) { let Kongregate;
return Kongregate = class Kongregate {
  constructor() {}
  isKongregate() {
    return isKongregate();
  }
  load() {
    $log.debug('loading kongregate script...');
    const onLoad = $q.defer();
    this.onLoad = onLoad.promise;
    this.onLoad.then((() => this._onLoad()), console.warn);
    try {
      this.kongregate = window.parent.kongregate;
      this.parented = window.parent.document.getElementsByTagName('iframe')[0];
    } catch (e) {}
      // pass - no kongregate_shell.html, or kongregate api's blocked in it. try to load the api ourselves
    if (this.kongregate) {
      $log.debug('kongregate api loaded from parent frame');
      onLoad.resolve();
      return;
    }
    return $.getScript('https://cdn1.kongregate.com/javascripts/kongregate_api.js')
      .done((script, textStatus, xhr) => {
        $log.debug('kongregate script loaded, now trying to load api', window.kongregateAPI);
        // loadAPI() requires an actual kongregate frame, `?kongregate=1` in its own tab is insufficient. fails silently.
        return window.kongregateAPI.loadAPI(() => {
          $log.debug('kongregate api loaded');
          this.kongregate = window.kongregateAPI.getAPI();
          return onLoad.resolve();
        });
    }).fail((xhr, settings, exception) => {
        $log.error('kongregate load failed', xhr, settings, exception);
        return onLoad.reject();
    });
  }

  onResize() {} //overridden on load
  _onResize() {} //overridden on load
  _resizeGame(w, h) {
    this.kongregate.services.resizeGame(Math.max(options.iframeMinX(), w != null ? w : 0), Math.max(options.iframeMinY(), h != null ? h : 0));
    if (this.parented) {
      // kongregate resizes its shell instead of my game. scroll lock demands my game have the scrollbar, not the iframe.
      h = this.parented.style.height;
      w = this.parented.style.width;
      this.parented.style.height = '100%';
      this.parented.style.width = '100%';
      document.documentElement.style.height = h;
      return document.documentElement.style.width = w;
    }
  }
  onScrollOptionChange(noresizedefault, oldscroll) {
    const scrolling = options.scrolling();
    $log.debug('updating kong scroll option', scrolling);

    if (scrolling === 'resize') {
      // no blinking scrollbar on resize. https://stackoverflow.com/questions/2469529/how-to-disable-scrolling-the-document-body
      document.body.style.overflow = 'hidden';
      this.onResize = this._onResize;
      // selecting autoresize should always trigger a resize
      this.onResize(true);
    } else {
      document.body.style.overflow = '';
      this.onResize = function() {};
    }

    if (scrolling === 'lockhover') {
      this.bindLockhover();
    } else {
      this.unbindLockhover();
    }

    if ((scrolling !== 'resize') && (oldscroll === 'resize') && this.isLoaded && !noresizedefault) {
      return this._resizeGame(null, null);
    }
  }

  unbindLockhover() {
    return $('html').off('DOMMouseScroll mousewheel');
  }
  bindLockhover() {
    // heavily based on https://stackoverflow.com/questions/5802467/prevent-scrolling-of-parent-element
    const body = $('body')[0];
    const $both = $('body,html');
    return $('html').on('DOMMouseScroll mousewheel', function(ev) {
      let delta;
      const $this = $(this);
      const scrollTop = this.scrollTop || body.scrollTop;
      const {
        scrollHeight
      } = this;
      //height = $this.height()
      //height = $this.outerHeight true
      const height = window.innerHeight;
      if (ev.type === 'DOMMouseScroll') {
        delta = ev.originalEvent.detail * -40;
      } else {
        delta = ev.originalEvent.wheelDelta;
      }
      const up = delta > 0;
      // not even log.debugs; scroll events are performance-sensitve.
      //console.log 'mousewheelin', delta, up, scrollTop, scrollHeight, height

      const prevent = function() {
        ev.stopPropagation();
        ev.preventDefault();
        ev.returnValue = false;
        return false;
      };

      //console.log 'mousewheelin check down', !up, -delta, scrollHeight - height - scrollTop
      //console.log 'mousewheelin check up', up, delta, scrollTop
      if (!up && (-delta > (scrollHeight - height - scrollTop))) {
        //console.log 'mousewheelin blocks down', delta, up
        // Scrolling down, but this will take us past the bottom.
        $both.scrollTop(scrollHeight);
        return prevent();
      } else if (up && (delta > scrollTop)) {
        // Scrolling up, but this will take us past the top.
        //console.log 'mousewheelin blocks up', delta, up
        $both.scrollTop(0);
        return prevent();
      }
    });
  }

  // Login to swarmsim using Kongregate userid/token as credentials.
  _swarmApiLogin() {
    if (!env.isServerBackendEnabled) {
      return;
    }
    const doLogin = () => {
      $log.debug('kongregate swarmapi login...');
      return loginApi.login('kongregate', {
        user_id: this.kongregate.services.getUserId(),
        game_auth_token: this.kongregate.services.getGameAuthToken(),
        // not needed for auth, but updates visible username
        username: this.kongregate.services.getUsername()
      }).success((data, status, xhr) => $log.debug('kongregate swarmapi login success', data, status, xhr)).error((data, status, xhr) => $log.debug('kongregate swarmapi login error', data, status, xhr));
    };
    if (this.kongregate.services.isGuest()) {
      $log.debug('kongregate swarmapi guest login...');
      loginApi.login('guestuser')
      .success((data, status, xhr) => $log.debug('kongregate swarmapi guest login success', data, status, xhr)).error((data, status, xhr) => $log.debug('kongregate swarmapi guest login error', data, status, xhr));
    } else {
      doLogin();
    }
    // upgrade guest logins later
    return this.kongregate.services.addEventListener('login', doLogin);
  }

  _onLoad() {
    $log.debug('kongregate successfully loaded!', this.kongregate);
    this.isLoaded = true;
    this.reportStats();

    this._swarmApiLogin();

    // configure resizing iframe
    const html = $(document.documentElement);
    const body = $(document.body);
    let oldheight = null;
    let olddate = new Date(0);
    this._onResize = force => {
      //height = Math.max html.height(), body.height(), 600
      const height = Math.max(body.height(), 600);
      if ((height !== oldheight) || force) {
        const date = new Date();
        const datediff = date.getTime() - olddate.getTime();
        // jumpy height changes while rendering, especially in IE!
        // throttle height decreases to 1 per second, to avoid some of the
        // jumpiness. height increases must be responsive though, so don't
        // throttle those. seems to be enough. (if this proves too jumpy, could
        // add a 100px buffer to size increases, but not necessary yet I think.)
        if ((height > oldheight) || ((datediff >= 1000) && ((oldheight - height) > 100)) || force) {
          $log.debug(`onresize: ${oldheight} to ${height} (${height > oldheight ? 'up' : 'down'}), ${datediff}ms`);
          oldheight = height;
          olddate = date;
          this._resizeGame(800, height);
          if (this.parented) {
            return this.parented.style.height = height+'px';
          }
        }
      }
    };
    this.onScrollOptionChange(true);
    // resize whenever size changes.
    //html.resize onResize
    // NOPE. can't detect page height changes with standard events. header calls onResize every frame.
    return $log.debug('setup onresize');
  }

  reportStats() {
    try {
      if (!this.isLoaded || !game.session.state.kongregate) {
        return;
      }
      // don't report more than once per minute
      const now = new Date();
      if (this.lastReported && (now.getTime() < (this.lastReported.getTime() + (60 * 1000)))) {
        return;
      }
      //if not @lastReported
      //  @kongregate.stats.submit 'Initialized', 1
      this.lastReported = now;
      this.kongregate.stats.submit('Hatcheries', this._count(game.upgrade('hatchery')));
      this.kongregate.stats.submit('Expansions', this._count(game.upgrade('expansion')));
      this.kongregate.stats.submit('GameComplete', this._count(game.unit('ascension')));
      this.kongregate.stats.submit('Mutations Unlocked', this._count(game.upgrade('mutatehidden')));
      this.kongregate.stats.submit('Achievement Points', game.achievementPoints());
      this._submitTimetrialMins('Minutes to First Nexus', game.upgrade('nexus1'));
      this._submitTimetrialMins('Minutes to Fifth Nexus', game.upgrade('nexus5'));
      return this._submitTimetrialMins('Minutes to First Ascension', game.unit('ascension'));
    } catch (e) {
      return $log.warn('kongregate reportstats failed - continuing', e);
    }
  }

  _count(u) {
    return u.count().floor().toNumber();
  }
  _timetrialMins(u) {
    let millis;
    if (millis = __guard__(u.statistics(), x => x.elapsedFirst)) {
      return Math.ceil(millis / 1000 / 60);
    }
  }
  _submitTimetrialMins(name, u) {
    const time = this._timetrialMins(u);
    if (time) {
      return this.kongregate.stats.submit(name, time);
    }
  }
};
 });

angular.module('swarmApp').factory('kongregate', function($log, Kongregate) {
  const ret = new Kongregate();
  $log.debug('isKongregate:', ret.isKongregate());
  if (ret.isKongregate()) {
    ret.load();
  }
  return ret;
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}