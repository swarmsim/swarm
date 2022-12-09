/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: statistics', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let statistics = {};
  beforeEach(inject(_statistics_ => statistics = _statistics_)
  );

  return it('should do something', () => expect(!!statistics).toBe(true));
});
