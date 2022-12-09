/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: flashqueue', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let flashqueue = {};
  beforeEach(inject(_flashqueue_ => flashqueue = _flashqueue_)
  );

  return it('should do something', () => expect(!!flashqueue).toBe(true));
});
