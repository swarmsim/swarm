/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: analytics', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let analytics = {};
  beforeEach(inject(_analytics_ => analytics = _analytics_)
  );

  // TODO why on earth does this fail in travis-ci? Works fine in my checkout.
  return xit('should do something', () => expect(!!analytics).toBe(true));
});
