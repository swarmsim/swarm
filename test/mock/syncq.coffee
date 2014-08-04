'use strict'

# Synchronously-resolved deferrals ($q). Call $apply() whenever
# resolve/reject/notify are called, to ease testing.
#
# Usage:
#   beforeEach module 'mockSyncQ'
angular.module('mockSyncQ', []).config ($provide) ->
  $provide.decorator '$q', ($delegate, $rootScope) ->
    class SyncQ
      constructor: (@$q, @$rootScope) ->
      defer: (args...) ->
        new SyncDeferred @$rootScope, @$q.defer args...

    class SyncDeferred
      constructor: (@$rootScope, @deferred) ->
        # original promise, nothing to patch here
        @promise = @deferred.promise
      resolve: (args...) ->
        ret = @deferred.resolve args...
        @$rootScope.$apply()
        return ret
      reject: (args...) ->
        ret = @deferred.reject args...
        @$rootScope.$apply()
        return ret
      notify: (args...) ->
        ret = @deferred.notify args...
        @$rootScope.$apply()
        return ret

    return new SyncQ $delegate, $rootScope

