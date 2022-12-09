'use strict'
import _ from 'lodash'

###*
 # @ngdoc filter
 # @name swarmApp.filter:moment
 # @function
 # @description
 # # moment
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'duration', (options, $filter) ->
  ret = (input, unitOfTime, template, precision) ->
    if input is Infinity
      return ''
    if _.isNaN(input)
      #return 'almost forever'
      # https://www.reddit.com/r/swarmsim/comments/6e11pz/bug_faster_overmind_iv_progress_bar_says_almost/?st=j3q8s9vi&sh=617fdcef
      return ''
    if input.toNumber?
      input = input.toNumber()
    return '' if not input
    nonexact = if input?.nonexact?  and input.nonexact then ' or less' else ''
    duration = moment.duration input, unitOfTime
    if not template?
      template = 'd[d] h:mm:ss'
      switch options.durationFormat?()
        when 'human' then return nonexact + duration.humanize()
        when 'full'
          template = switch
            when duration.asSeconds() < 60 then '0:s'
            else 'y [yr] M [mth] d [day] hh:mm:ss'
        when 'abbreviated'
          if duration.asYears() >= 100
            years = $filter('longnum')(duration.asYears())
            return "#{years} years"
          template = switch
            when duration.asYears() >= 1 then 'y [years] M [months]'
            when duration.asMonths() >= 1 then 'M [months] d [days]'
            when duration.asDays() >= 1 then 'd [days] h [hours]'
            when duration.asMinutes() >= 1 then 'h:mm:ss'
            else {template:'00:ss', trim:false}

    return duration.format(template, precision) + nonexact
  # http://blog.thoughtram.io/angularjs/2014/11/19/exploring-angular-1.3-stateful-filters.html
  # TODO: make this stateless, with params, so angular can optimize. For now, $stateful keeps
  # the old behavior and avoids overcaching.
  ret.$stateful = true
  return ret

angular.module('swarmApp').filter 'momentFromNow', ($filter) ->
  (input) ->
    return moment(input).fromNow()
