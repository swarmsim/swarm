'use strict'
import {Decimal} from 'decimal.js'

###*
 # @ngdoc function
 # @name swarmApp.controller:DecimallegendCtrl
 # @description
 # # DecimallegendCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'DecimallegendCtrl', ($scope, numberSuffixesShort, numberSuffixesLong, $log) ->
  zipped = _.zip [0...numberSuffixesShort.length], numberSuffixesShort, numberSuffixesLong
  $scope.rows = ({
    rownum:z[0]
    short:z[1]
    long:z[2]
    val:new Decimal "1e#{(z[0] or 0)*3}"
    string:"1e#{(z[0] or 0)*3}"
  } for z in zipped)
  $scope.rows[0].string += " (1)"
  $scope.rows[1].string += " (1,000)"
  $scope.rows[2].string += " (1,000,000)"
  $log.debug $scope.rows
