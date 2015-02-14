'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:moment
 # @function
 # @description
 # # moment
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'duration', ->
  (input, unitOfTime, template='d[d] h:mm:ss', precision) ->
    if input.toNumber?
      input = input.toNumber()
    duration = moment.duration input, unitOfTime
    return duration.format template, precision

# could just pass the template from the view, but this is testable
angular.module('swarmApp').filter 'warpDuration', ($filter) ->
  (input, unitOfTime, precision) ->
    $filter('duration')(input, unitOfTime, 'd [days] h [hours and] m [minutes]', precision)
