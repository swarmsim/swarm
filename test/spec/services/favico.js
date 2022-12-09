/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: favico', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let favico = {};
  beforeEach(inject(_favico_ => favico = _favico_)
  );

  return it('should do something', () => expect(!!favico).toBe(true));
});
