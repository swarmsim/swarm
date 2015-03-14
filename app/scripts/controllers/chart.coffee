
angular.module('swarmApp').controller 'ChartCtrl', ($scope, $log ,game ,options ) ->
  $scope.game = game

  chart1 = {}
  chart1.type = 'PieChart'

  chart1.options =
    displayExactValues: true
    is3D: true
    title: 'Units'
    sliceVisibilityThreshold: 0
    legend:
      position: 'labeled'
      maxLines: 12

  chart1.formatters =  {
    number : [{
        columnNum: 1,
        pattern: "##0.00E0"
        fractionDigits: 0
      }]
  }

  $scope.unitchart = chart1

  chart2 = {}
  chart2.type = 'PieChart'


  chart2.options =
    displayExactValues: true
    is3D: true
    title: 'Production'
    sliceVisibilityThreshold: 0
    legend:
      position: 'labeled'
      maxLines: 12

  chart2.formatters =  {
    number : [{
        columnNum: 1,
        pattern: "##0.00E0"
        fractionDigits: 0
      }]
  }

  $scope.prodchart = chart2

  $scope.updatecharts = () ->
    $log.debug "updating chart data"
    #populate data.. move this to function so it can update.
    # also need to get the 'correct' units
    chart1.data = [ ["Unit Name", "Qty" ] ]
    chart2.data = [ ["Unit Name", "Production" ] ]
    for unit in $scope.game.tabs.byName.territory.sortedUnits when unit && unit.name != "territory" #&& !unit.count().isZero()
      #$log.debug unit
      #need Number() for full pie.. will die with bignumbers!!!
      chart1.data.push [ unit.type.label , Number(unit.count() )]
      chart2.data.push [ unit.type.label , Number(unit.totalProduction().territory )]

  $scope.updatecharts()
