/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: playfab', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let playfab = {};
  beforeEach(inject(_playfab_ => playfab = _playfab_)
  );

  return it('should do something', () => expect(!!playfab).toBe(true));
});
