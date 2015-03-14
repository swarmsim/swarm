
angular.module('swarmApp').controller 'ChartCtrl', ($scope, $log, game, options) ->
  $scope.game = game
  $scope.options = options

  $scope.prodchart = prodchart =
    type: 'PieChart'

  totalVelocity = $scope.game.unit('territory').velocity()
  prodchart.options =
    #displayExactValues: false
    #is3D: true
    title: 'Production Rates'
    sliceVisibilityThreshold: totalVelocity.dividedBy 100
    # tooltips refuse to display bignums properly, so don't show it at all
    tooltip: {trigger:'none'}
    legend:
      position: 'labeled'
      maxLines: 12

  $scope.updatecharts = ->
    $log.debug "updating chart data"
    #populate data.. move this to function so it can update.
    # also need to get the 'correct' units
    prodchart.data = [ ["Unit Name", "Production" ] ]
    for unit in $scope.game.tabs.byName.territory.sortedUnits
      if unit.isVisible() and unit.name != "territory"
        #$log.debug unit
        #need Number() for full pie.. will die with bignumbers!!!
        prodchart.data.push [unit.type.label, unit.totalProduction().territory.dividedBy(totalVelocity).toNumber()]

  # this works since you can't buy territory units with the chart visible
  $scope.updatecharts()
