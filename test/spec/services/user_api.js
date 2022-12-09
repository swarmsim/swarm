/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: userApi', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let userApi = {};
  beforeEach(inject(_userApi_ => userApi = _userApi_)
  );

  return it('should do something', () => expect(!!userApi).toBe(true));
});
