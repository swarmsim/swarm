/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: Backfill', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let Backfill = {};
  beforeEach(inject(_Backfill_ => Backfill = _Backfill_)
  );

  return it('should do something', () => expect(!!Backfill).toBe(true));
});
