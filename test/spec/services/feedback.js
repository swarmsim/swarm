/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: feedback', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let feedback = {};
  beforeEach(inject(_feedback_ => feedback = _feedback_)
  );

  return it('should do something', () => expect(!!feedback).toBe(true));
});
