/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: mtx', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let mtx = {};
  beforeEach(inject(_mtx_ => mtx = _mtx_)
  );

  return it('should do something', () => expect(!!mtx).toBe(true));
});
