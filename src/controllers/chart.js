/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */

angular.module('swarmApp').controller('ChartCtrl', function($scope, $log, game, options) {
  let prodchart;
  $scope.game = game;
  $scope.options = options;

  $scope.prodchart = (prodchart =
    {type: 'PieChart'});

  // https://developers.google.com/chart/interactive/docs/gallery/piechart#Configuration_Options
  const textStyle = {
    color: $('body').css('color'),
    fontName: $('body').css('font'),
    fontSize: $('body').css('font-size')
  };
  prodchart.options = {
    backgroundColor: $('body').css('background-color'),
    titleTextStyle: textStyle,
    fontName: textStyle.fontName,
    fontSize: textStyle.fontSize,
    chartArea: {
      backgroundColor: $('body').css('background-color')
    },
    pieSliceBorderColor: $('body').css('background-color'),
    pieResidueSliceLabel: 'Other', //by default, this is translated to the browser language - inconsistent with the rest of the game
    legend: {
      position: 'labeled',
      textStyle
    },
    // this overlays slice colors, some themes are unreadable that way. use the default white.
    pieSliceTextStyle: _.omit(textStyle, 'color'),
    //displayExactValues: false
    //is3D: true
    title: 'Production Rates',
    sliceVisibilityThreshold: 0.01,
    // tooltips refuse to display bignums properly, so don't show it at all
    tooltip: {trigger:'none'}
  };

  const totalVelocity = $scope.game.unit('territory').velocity();
  $scope.updatecharts = function() {
    $log.debug("updating chart data");
    //populate data.. move this to function so it can update.
    // also need to get the 'correct' units
    prodchart.data = [ ["Unit Name", "Production" ] ];
    return (() => {
      const result = [];
      for (var unit of Array.from($scope.game.tabs.byName.territory.sortedUnits)) {
        if (unit.isVisible() && (unit.name !== "territory")) {
          //$log.debug unit
          //need Number() for full pie.. will die with bignumbers!!!
          result.push(prodchart.data.push([unit.type.label, unit.totalProduction().territory.dividedBy(totalVelocity).toNumber()]));
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  };

  // this works since you can't buy territory units with the chart visible
  return $scope.updatecharts();
});
