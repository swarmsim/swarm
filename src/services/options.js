/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';
import $ from 'jquery';

/**
 * @ngdoc service
 * @name swarmApp.options
 * @description
 * # options
 * Service in the swarmApp.
*/
angular.module('swarmApp').factory('Options', function($log, util, env, game, $location) { let Options;
return Options = (function() {
  Options = class Options {
    static initClass() {
  
      this.IFRAME_X_MIN = 800;
      this.IFRAME_Y_MIN = 600;
  
      // can't attach an id to the theme element - usemin-compiled
      this.THEME_EL = $('link[href^="styles/bootstrapdefault"]');
      this.THEMES = (function() {
        // don't assert this in dev because it breaks tests
        util.assert((env.isDebugEnabled || Options.THEME_EL[0]), "couldn't find theme link");
        const ret =
          {list: []};
        ret.list.push({
          name: 'none',
          label: 'Default white',
          //url: '//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css'
          url: Options.THEME_EL.attr('href'),
          credit: 'http://bootswatch.com/default/'
        });
        // bootswatch themes
        for (var name of ['cerulean', 'cosmo', 'cyborg', 'darkly', 'flatly', 'journal', 'lumen', 'paper', 'readable', 'sandstone', 'simplex', 'slate', 'spacelab', 'superhero', 'united', 'yeti']) {
          ret.list.push({
            name,
            label: name,
            //url: "//maxcdn.bootstrapcdn.com/bootswatch/3.3.2/#{name}/bootstrap.min.css" # why do people block the cdn srsly
            url: `bower_components/bootswatch/${name}/bootstrap.min.css`,
            credit: `http://bootswatch.com/${name}/`
          });
        }
        ret.byName = _.keyBy(ret.list, 'name');
        return ret;
      })();
  
      this.THEME_EXTRA_LENGTH = 1000;
    }
    constructor(session) {
      this.session = session;
      this.VELOCITY_UNITS = {byName:{}, list:[]};
      const addvunit = (name, label, plural, mult) => {
        const vu = {name, label, plural, mult};
        if (_.isFunction(mult)) {
          vu._get = function() {
            const ret = _.clone(this);
            ret.mult = ret.mult();
            return ret;
          };
        } else {
          vu._get = function() { return this; };
        }
        this.VELOCITY_UNITS.byName[vu.name] = vu;
        return this.VELOCITY_UNITS.list.push(vu);
      };
      addvunit('sec', 'second', 'seconds', 1);
      addvunit('min', 'minute', 'minutes', 60);
      addvunit('hr', 'hour', 'hours', 60 * 60);
      addvunit('day', 'day', 'days', 60 * 60 * 24);
      addvunit('warp', 'Swarmwarp', 'Swarmwarps', () => game.upgrade('swarmwarp').effect[0].output());
    }

    maybeSet(field, val, valid) {
      if (val != null) {
        $log.debug('set options value', field, val);
        if (valid != null) {
          util.assert(valid[val], `invalid option for ${field}: ${val}`);
        }
        return this.set(field, val);
      }
    }
    set(field, val) {
      this.session.state.options[field] = val;
      return this.session.save();
    }
    get(field, default_) {
      return this.session.state.options[field] != null ? this.session.state.options[field] : default_;
    }
    reset(field) {
      return delete this.session.state.options[field];
    }

    fpsAuto(enabled) {
      this.maybeSet('fpsAuto', enabled);
      // fpsAuto defaults to true if neither fps or fpsAuto are explicitly set
      // fpsAuto is false if fps-only is explicitly set
      // @get 'fpsAuto', !(@get('fps')?)
      return this.get('fpsAuto', false);
    }

    fps(val) {
      this.maybeSet('fps', val);
      return Math.min(60, Math.max(0.0001, this.get('fps', 10)));
    }

    fpsSleepMillis() {
      return 1000 / this.fps();
    }

    showAdvancedUnitData(val) {
      this.maybeSet('showAdvancedUnitData', val);
      return !!this.get('showAdvancedUnitData');
    }

    durationFormat(val) {
      if (val != null) {
        const valid = {'human':true, 'full':true, 'abbreviated':true};
        util.assert(valid[val], 'invalid options.durationFormat value', val);
        this.maybeSet('durationFormat', val);
      }
      return this.get('durationFormat', 'abbreviated');
    }

    notation(val) {
      if (val != null) {
        const valid = {'standard-decimal':true, 'scientific-e':true, 'hybrid':true, 'engineering':true};
        util.assert(valid[val], 'invalid options.notation value', val);
        this.maybeSet('notation', val);
      }
      return this.get('notation', 'standard-decimal');
    }

    velocityUnit(name, opts) {
      if (opts == null) { opts = {}; }
      this.maybeSet('velocityUnit', name, this.VELOCITY_UNITS.byName);
      let ret = this.VELOCITY_UNITS.byName[this.get('velocityUnit')];
      // special case: swarmwarp produces no energy, so default to seconds
      if (((ret == null)) || ((ret.name === 'warp') && (
        (((opts.unit != null ? opts.unit.name : undefined) != null ? (opts.unit != null ? opts.unit.name : undefined) : opts.unit) === 'energy') ||
        (((opts.prod != null ? opts.prod.name : undefined) != null ? (opts.prod != null ? opts.prod.name : undefined) : opts.prod) === 'nexus'))
      )) {
        ret = this.VELOCITY_UNITS.list[0];
      }
      return ret._get();
    }
    getVelocityUnit(opts) {
      if (opts == null) { opts = {}; }
      return this.velocityUnit(undefined, opts);
    }

    // Scrolling style on kongregate/iframed pages
    scrolling(name) {
      let left;
      this.maybeSet('scrolling', name, {'none':true, 'resize':true, 'lockhover': 'lockhover'});
      return (left = this.get('scrolling')) != null ? left : 'none';
    }
    iframeMinX(x) {
      this.maybeSet('iframeMinX', x);
      return Math.max((this.get('iframeMinX') || 0), this.constructor.IFRAME_X_MIN);
    }
    iframeMinY(y) {
      this.maybeSet('iframeMinY', y);
      return Math.max((this.get('iframeMinY') || 0), this.constructor.IFRAME_Y_MIN);
    }

    autopush(enabled) {
      let left;
      this.maybeSet('autopush', enabled);
      return (left = this.get('autopush')) != null ? left : true;
    }

    theme(name) {
      // getter for both theme and customTheme
      if (name != null) {
        this.set('isCustomTheme', false);
        this.maybeSet('theme', name, Options.THEMES.byName);
      }

      if (this.get('isCustomTheme')) {
        return this.get('theme');
      } else {
        let left;
        name = (left = this.get('theme')) != null ? left : 'none';
        // legacy themes. pick another dark theme.
        if ((name === 'dark-ff') || (name === 'dark-chrome')) {
          name = 'slate';
        }
        return Options.THEMES.byName[name];
      }
    }

    customTheme(url) {
      this.set('isCustomTheme', true);
      return this.set('theme', {isCustom:true,url});
    }

    showCharts(enabled) {
      let left;
      this.maybeSet('showCharts', enabled);
      return (left = this.get('showCharts')) != null ? left : true;
    }
    themeExtra(css) {
      if (css != null) {
        if (css.length >= this.constructor.THEME_EXTRA_LENGTH) {
          throw new Error("But it's so big!");
        }
        this.set('themeExtra', css);
      }
      if (this.isAprilFoolsTheme() && (this.aprilFoolsState() === 'on')) {
        return "@import url('/static/kittens.css?1');";
      }
      return this.get('themeExtra', null);
    }

    // options is a strange place for this, but themeExtra needs it
    aprilFoolsState() {
      // ?forcefools=[on|after|off] to force this state for testing, no clock-changes required
      let ret;
      if ((ret=$location.search().forcefools) != null) {
        return ret;
      }

      const now = moment();
      // test times.
      // off (before)
      //now = moment.parseZone '2015-03-31T23:00:00-05:00' # because moment.parseZone('2015-03-31T23:00:00-05:00').isBefore('2015-03-31T21:00:00-08:00')
      // on
      //now = moment.parseZone '2015-03-31T21:05:00-08:00'
      //now = moment.parseZone '2015-04-01T00:01:00-05:00'
      // after
      //now = moment.parseZone '2015-04-01T21:00:00-08:00'
      //now = moment.parseZone '2015-04-03T21:00:00-08:00'
      // off (after)
      //now = moment.parseZone '2015-04-04T21:00:00-08:00'

      // use the same timezone for everyone, so it appears at around the same time for everyone and earlier timezones don't spoil it.
      // this means it starts at the wrong time for non-americans, whom we have lots of. oh well, a consistent start is more important; sorry folks.
      // start a few hours early, between 3/31 21:00 PST (00:00 EST) and 4/1 00:00 PST
      // -07:00 (not -08:00) because daylight savings
      //year = 2015
      // Sadly, I won't be writing april fools events every year after all. Just make this one run every year.
      const year = new Date().getFullYear();
      if (now.isBetween(moment.parseZone(year+'-03-31T21:00:00-07:00'), moment.parseZone(year+'-04-02T00:00:00-07:00'))) {
        return 'on';
      }
      if (now.isBetween(moment.parseZone(year+'-04-02T00:00:00-07:00'), moment.parseZone(year+'-04-04T00:00:00-07:00'))) {
        return 'after';
      }
      return 'off';
    }
    isAprilFoolsTheme(enabled) {
      let left;
      this.maybeSet('aprilFoolsTheme', enabled);
      return (left = this.get('aprilFoolsTheme')) != null ? left : false;
    }
  };
  Options.initClass();
  return Options;
})();
 });


angular.module('swarmApp').factory('options', (Options, session) => new Options(session));
