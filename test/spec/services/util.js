/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: util', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let util = {};
  beforeEach(inject(_util_ => util = _util_)
  );

  it('should do something', () => expect(!!util).toBe(true));

  it('sums', function() {
    expect(util.sum([])).toBe(0);
    expect(util.sum([1,2,3])).toBe(6);
    return expect(util.sum([1,2,-3])).toBe(0);
  });

  return it('imports decimal.js bignums', function() {
    expect(!!window.Decimal).toBe(true);
    expect(!!Decimal).toBe(true);
    return expect(new Decimal('1e+500').times(2).toString()).toBe('2e+500');
  });
});
