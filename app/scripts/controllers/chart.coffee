
angular.module('swarmApp').controller 'ChartCtrl', ($scope, $log ,game ) ->
  $log.debug "init chart controller"

  chart1 = {}
  chart1.type = 'PieChart'
  chart1.data = [ ["Unit Name", "Qty" ] ]

  uns = game.units()
  $log.debug 'uns=',uns

  $log.debug "do looping"
  #populate data.. move this to function so it can update.
  # also need to get the 'correct' units
  for unit in game.tabs.byName.meat.sortedUnits when unit.name != "meat" && !unit.count().isZero()
    $log.debug "unit:",unit.name, unit.count().toFixed(0)
    chart1.data.push [ unit.name , Number(unit.count() )]  #need NUmber for full pie.. will die with bignumbers!!!

  chart1.options =
    displayExactValues: true
    is3D: false
    title: 'Meat Percentages'
    legend:
      maxLines: 12

  chart1.formatters =  {}

  $scope.chart = chart1

