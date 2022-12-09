/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: options', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let options = {};
  beforeEach(inject(_options_ => options = _options_)
  );

  it('should do something', () => expect(!!options).toBe(true));

  it('sets velocity', function() {
    expect(options.VELOCITY_UNITS.list.length).toBeGreaterThan(0);
    return (() => {
      const result = [];
      for (var vu of Array.from(options.VELOCITY_UNITS.list)) {
        options.velocityUnit(vu.name);
        result.push(expect(options.velocityUnit().name).toBe(vu.name));
      }
      return result;
    })();
  });

  return it('special-cases Swarmwarp velocity', function() {
      options.velocityUnit('warp');
      expect(options.velocityUnit().name).toBe('warp');
      expect(options.velocityUnit().mult+'').toBe('900');
      expect(options.getVelocityUnit({unit:'drone'}).name).toBe('warp');
      expect(options.getVelocityUnit({unit:'drone'}).mult+'').toBe('900');
      // energy is a special case: swarmwarp generates no energy
      expect(options.getVelocityUnit({unit:'energy'}).name).toBe('sec');
      return expect(options.getVelocityUnit({unit:'energy'}).mult+'').toBe('1');
  });
});
