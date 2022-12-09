/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: seedrand', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let seedrand = {};
  beforeEach(inject(_seedrand_ => seedrand = _seedrand_)
  );

  it('should do something', () => expect(!!seedrand).toBe(true));

  return it('generates deterministic random numbers', function() {
    expect(seedrand.rand('x', 'y')).not.toEqual(seedrand.rand('x', 'z'));
    expect(seedrand.rand('x', 'y')).not.toEqual(seedrand.rand('w', 'y'));
    expect(seedrand.rand('x', 'y')).not.toEqual(seedrand.rand('y', 'x'));
    expect(seedrand.rand('x', 'y')).toEqual(seedrand.rand('x', 'y'));
    expect(seedrand.rand('x', 'y')).toEqual(seedrand.rand('x', 'y'));
    return expect(seedrand.rand('x', 'y')).toEqual(seedrand.rand('x', 'y'));
  });
});
