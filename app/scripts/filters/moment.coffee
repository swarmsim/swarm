'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:moment
 # @function
 # @description
 # # moment
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'duration', (options, $filter) ->
  (input, unitOfTime, template, precision) ->
    if input is Infinity
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
# could just pass the template from the view, but this is testable
angular.module('swarmApp').filter 'warpDuration', ($filter) ->
  (input, unitOfTime, precision) ->
    if unitOfTime is 'seconds' and input instanceof Decimal and input.toNumber() > 15*60 and input.toNumber() < 60*60
      # this triggers only if the warp time is between 15 minutes and 60 minutes, and gives us second-level precision
      # this filter *should* be called only if (unitOfTime is 'seconds' and input instanceof Decimal) - those are mostly there for sanity
      # we drop seconds if we're calculating more than an hour, just because it's cluttered
      # and if we're less than or equal to 15 minutes, because that way it's less confusing for new players
      $filter('duration')(input, unitOfTime, 'd [days] h [hours] m [minutes and] s [seconds]', precision)
    else
      $filter('duration')(input, unitOfTime, 'd [days] h [hours and] m [minutes]', precision)
    

angular.module('swarmApp').filter 'momentFromNow', ($filter) ->
  (input) ->
    return moment(input).fromNow()
