'use strict'

describe 'mock: syncq', ->

  # load the service's module
  beforeEach module 'mockSyncQ'

  # instantiate service
  #spreadsheet = {}
  $q = {}
  $rootScope = {}
  beforeEach inject (_$q_, _$rootScope_) ->
    $q = _$q_
    $rootScope = _$rootScope_

  it 'should resolve promises properly while testing', (done) ->
    # ffs this took me 2 hours to figure out
    deferred = $q.defer()
    promise = deferred.promise
    promise.then ->
      done()
    deferred.resolve 'yay'

  it 'should reject', (done) ->
    deferred = $q.defer()
    promise = deferred.promise
    promise.then (->), ->
      done()
    deferred.reject 'boo'

  it 'should notify', (done) ->
    deferred = $q.defer()
    promise = deferred.promise
    promise.then (->), (->), ->
      done()
    deferred.notify 'meh'
