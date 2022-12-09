/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('mock: syncq', function() {

  // load the service's module
  beforeEach(module('mockSyncQ'));

  // instantiate service
  //spreadsheet = {}
  let $q = {};
  let $rootScope = {};
  beforeEach(inject(function(_$q_, _$rootScope_) {
    $q = _$q_;
    return $rootScope = _$rootScope_;
  })
  );

  it('should resolve promises properly while testing', function(done) {
    // ffs this took me 2 hours to figure out
    const deferred = $q.defer();
    const {
      promise
    } = deferred;
    promise.then(() => done());
    return deferred.resolve('yay');
  });

  it('should reject', function(done) {
    const deferred = $q.defer();
    const {
      promise
    } = deferred;
    promise.then((function() {}), () => done());
    return deferred.reject('boo');
  });

  return it('should notify', function(done) {
    const deferred = $q.defer();
    const {
      promise
    } = deferred;
    promise.then((function() {}), (function() {}), () => done());
    return deferred.notify('meh');
  });
});
