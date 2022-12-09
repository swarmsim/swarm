/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import _ from 'lodash';

/**
 * @ngdoc filter
 * @name swarmApp.filter:moment
 * @function
 * @description
 * # moment
 * Filter in the swarmApp.
*/
angular.module('swarmApp').filter('duration', function(options, $filter) {
  const ret = function(input, unitOfTime, template, precision) {
    if (input === Infinity) {
      return '';
    }
    if (_.isNaN(input)) {
      //return 'almost forever'
      // https://www.reddit.com/r/swarmsim/comments/6e11pz/bug_faster_overmind_iv_progress_bar_says_almost/?st=j3q8s9vi&sh=617fdcef
      return '';
    }
    if (input.toNumber != null) {
      input = input.toNumber();
    }
    if (!input) { return ''; }
    const nonexact = ((input != null ? input.nonexact : undefined) != null)  && input.nonexact ? ' or less' : '';
    const duration = moment.duration(input, unitOfTime);
    if ((template == null)) {
      template = 'd[d] h:mm:ss';
      switch ((typeof options.durationFormat === 'function' ? options.durationFormat() : undefined)) {
        case 'human': return nonexact + duration.humanize(); break;
        case 'full':
          template = (() => { switch (false) {
            case !(duration.asSeconds() < 60): return '0:s';
            default: return 'y [yr] M [mth] d [day] hh:mm:ss';
          } })();
          break;
        case 'abbreviated':
          if (duration.asYears() >= 100) {
            const years = $filter('longnum')(duration.asYears());
            return `${years} years`;
          }
          template = (() => { switch (false) {
            case !(duration.asYears() >= 1): return 'y [years] M [months]';
            case !(duration.asMonths() >= 1): return 'M [months] d [days]';
            case !(duration.asDays() >= 1): return 'd [days] h [hours]';
            case !(duration.asMinutes() >= 1): return 'h:mm:ss';
            default: return {template:'00:ss', trim:false};
          } })();
          break;
      }
    }

    return duration.format(template, precision) + nonexact;
  };
  // http://blog.thoughtram.io/angularjs/2014/11/19/exploring-angular-1.3-stateful-filters.html
  // TODO: make this stateless, with params, so angular can optimize. For now, $stateful keeps
  // the old behavior and avoids overcaching.
  ret.$stateful = true;
  return ret;
});

angular.module('swarmApp').filter('momentFromNow', $filter => input => moment(input).fromNow());
