'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:moment
 # @function
 # @description
 # # moment
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'duration', (options) ->
  (input, unitOfTime, template='d[d] h:mm:ss', precision) ->
    if input.toNumber?
      input = input.toNumber()
    input.nonlinear ?= false
    input.nonlinear = if input.nonlinear then 'less than ' else ''
    duration = moment.duration input, unitOfTime
    if template != 'd[d] h:mm:ss' then return input.nonlinear + duration.format template, precision
    switch options.durationFormat() 
      when 'human' then return input.nonlinear + duration.humanize()
      when 'full' then return input.nonlinear + duration.format 'y [yr] M [mth] d [day] hh:mm:ss'
      else return input.nonlinear + duration.format template, precision

# could just pass the template from the view, but this is testable
angular.module('swarmApp').filter 'warpDuration', ($filter) ->
  (input, unitOfTime, precision) ->
    $filter('duration')(input, unitOfTime, 'd [days] h [hours and] m [minutes]', precision)

angular.module('swarmApp').filter 'momentFromNow', ($filter) ->
  (input) ->
    return moment(input).fromNow()
