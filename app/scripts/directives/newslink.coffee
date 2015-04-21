'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:newslink
 # @description
 # # newslink
###
angular.module 'swarmApp'
  .directive 'newslink', ->
    restrict: 'EA'
    template: """
<p ng-if="env.isDebugEnabled" style="border:1px red solid">Swarm Simulator v1.1 is coming soon! <a data-toggle="modal" data-target="#newsmodal" href="javascript:">See what's changing</a>.</p>
<div class="modal fade" id="newsmodal" tabindex="-1" role="dialog" aria-labelledby="newsmodal-title" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div ng-include="'views/newsmodal.html'"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
"""
    link: (scope, element, attrs) ->
