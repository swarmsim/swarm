/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: Kongregate', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let Kongregate = {};
  beforeEach(inject(_Kongregate_ => Kongregate = _Kongregate_)
  );

  return it('should do something', () => expect(!!Kongregate).toBe(true));
});
