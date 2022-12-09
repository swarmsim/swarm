/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: spreadsheet', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let spreadsheet = {};
  beforeEach(inject(_spreadsheet_ => spreadsheet = _spreadsheet_)
  );

  return it('should do something', () => expect(!!spreadsheet).toBe(true));
});
