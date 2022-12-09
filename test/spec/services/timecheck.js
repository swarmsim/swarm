/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: timecheck', function() {

  beforeEach(module('swarmApp'));

  // instantiate service
  let timecheck = {};
  let format = {};
  beforeEach(inject(function(_timecheck_, timecheckerServerFormat) {
    timecheck = _timecheck_;
    return format = timecheckerServerFormat;
  })
  );

  it('should do something', () => expect(!!timecheck).toBe(true));

  // don't knwo why this fails in tests
  xit('fetches network time', function(done) {
    const res = timecheck.fetchNetTime();
    expect(!!res).toBe(true);
    return res.then(function(time) {
      expect(!!time.datetime).toBe(true);
      const datetime = moment(time.datetime);
      expect(!!datetime).toBe(true);
      return done();
    });
  });

  it('parses http-formatted dates', () => expect(timecheck._parseDate('Thu, 02 Oct 2014 07:34:29 GMT', format, true).isValid()).toBe(true));

  it('validates network time', function() {
    expect(timecheck._isNetTimeInvalid('Thu, 02 Oct 2013 07:34:29 GMT')).toBe(true); // copied from github headers
    expect(timecheck._isNetTimeInvalid(moment().format(format))).toBe(false);
    expect(timecheck._isNetTimeInvalid(moment(0).format(format))).toBe(true);
    expect(timecheck._isNetTimeInvalid(moment().add(14, 'days').format(format))).toBe(true);
    expect(timecheck._isNetTimeInvalid(moment().subtract(14, 'days').format(format))).toBe(true);
    expect(timecheck._isNetTimeInvalid(moment().add(1, 'month').format(format))).toBe(true);
    expect(timecheck._isNetTimeInvalid(moment().subtract(1, 'month').format(format))).toBe(true);
    expect(timecheck._isNetTimeInvalid(moment().add(1, 'year').format(format))).toBe(true);
    expect(timecheck._isNetTimeInvalid(moment().subtract(1, 'year').format(format))).toBe(true);
    // within threshold
    expect(timecheck._isNetTimeInvalid(moment().add(1, 'days').format(format))).toBe(false);
    expect(timecheck._isNetTimeInvalid(moment().subtract(1, 'days').format(format))).toBe(false);
    expect(timecheck._isNetTimeInvalid(moment().add(3, 'days').format(format))).toBe(false);
    return expect(timecheck._isNetTimeInvalid(moment().subtract(3, 'days').format(format))).toBe(false);
  });

  return it('accepts bogus time formats, preferring false negatives to false positives', function() {
    expect(timecheck._isNetTimeInvalid('fgsfds')).toBeNull();
    expect(timecheck._isNetTimeInvalid('The, 32 Jab 201A 25:61:62 AAA')).toBeNull();
    expect(timecheck._isNetTimeInvalid(null)).toBeNull();
    return expect(timecheck._isNetTimeInvalid(undefined)).toBeNull();
  });
});
    // TODO validate that errors are emitted and logged to analytics

describe('Service: versioncheck', function() {

  beforeEach(module('swarmApp'));

  // instantiate service
  let versioncheck = {};
  beforeEach(inject(_versioncheck_ => versioncheck = _versioncheck_)
  );
  return it('compares versions', function() {
    expect(versioncheck.compare('0.0.0', '0.0.1')).toBeLessThan(0);
    expect(versioncheck.compare('0.0.1', '0.0.0')).toBeGreaterThan(0);
    expect(versioncheck.compare('0.0.1', '0.0.1')).toBe(0);
    return expect(versioncheck.compare('0.99.99', '1.0.0')).toBeLessThan(0);
  });
});
