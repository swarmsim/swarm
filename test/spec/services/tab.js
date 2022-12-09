/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: tab', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let Tab = {};
  beforeEach(inject(_Tab_ => Tab = _Tab_)
  );

  return it('should do something', () => expect(!!Tab).toBe(true));
});
