/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

// Synchronously-resolved deferrals ($q). Call $apply() whenever
// resolve/reject/notify are called, to ease testing.
//
// Usage:
//   beforeEach module 'mockSyncQ'
angular.module('mockSyncQ', []).config($provide => $provide.decorator('$q', function($delegate, $rootScope) {
  class SyncQ {
    constructor($q, $rootScope1) {
      this.$q = $q;
      this.$rootScope = $rootScope1;
    }
    defer(...args) {
      return new SyncDeferred(this.$rootScope, this.$q.defer(...Array.from(args || [])));
    }
  }

  class SyncDeferred {
    constructor($rootScope1, deferred) {
      // original promise, nothing to patch here
      this.$rootScope = $rootScope1;
      this.deferred = deferred;
      this.promise = this.deferred.promise;
    }
    resolve(...args) {
      const ret = this.deferred.resolve(...Array.from(args || []));
      this.$rootScope.$apply();
      return ret;
    }
    reject(...args) {
      const ret = this.deferred.reject(...Array.from(args || []));
      this.$rootScope.$apply();
      return ret;
    }
    notify(...args) {
      const ret = this.deferred.notify(...Array.from(args || []));
      this.$rootScope.$apply();
      return ret;
    }
  }

  return new SyncQ($delegate, $rootScope);
}));

