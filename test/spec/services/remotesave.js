/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: remotesave', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let remotesave = {};
  beforeEach(inject(_remotesave_ => remotesave = _remotesave_)
  );

  return xit('should do something', () => expect(!!remotesave).toBe(true));
});
