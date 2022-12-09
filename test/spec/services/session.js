/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: session', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let session = {};
  beforeEach(inject(_session_ => session = _session_)
  );

  it('should do something', () => expect(!!session).toBe(true));

  it('saves/loads', function() {
    // tests are too quick, and I don't wanna bother with DI'ing date right now
    const origsaved = (session.state.date.saved = new Date(session.state.date.saved.getTime() - 1));
    const state = session._saves();
    expect(origsaved).not.toEqual(session.state.date.saved);

    // session is nonequal because of its class/ctor, so use an object for later compares
    const orig = _.clone(session.state);
    const loaded = session._loads(state);
    expect(orig.date.loaded).not.toEqual(loaded.date.loaded);
    delete orig.date.loaded;
    delete loaded.date.loaded;
    return expect(orig).toEqual(loaded);
  });

  it('saves/loads versionless', function() {
    let version;
    let encoded = session._saves();
    [version, encoded] = Array.from(session._splitVersionHeader(encoded));
    expect(encoded.indexOf('|')).toBeLessThan(0);
    const data = session._loads(encoded);
    return expect(!!data).toBe(true);
  });

  it('saves/loads versionful', function() {
    const encoded = session._saves();
    expect(encoded.indexOf('|')).not.toBeLessThan(0);
    const data = session._loads(encoded);
    return expect(!!data).toBe(true);
  });

  it('validates the save version programmatically', function() {
    expect(() => session._validateSaveVersion('0.1.0', '0.1.0')).not.toThrow();
    expect(() => session._validateSaveVersion('0.1.0', '0.1.30')).not.toThrow();
    // we're allowing older version imports
    expect(() => session._validateSaveVersion('0.1.30', '0.1.0')).not.toThrow();
    // but beta minor versions are a reset
    expect(() => session._validateSaveVersion('0.1.30', '0.2.0')).toThrow();
    expect(() => session._validateSaveVersion('0.2.30', '0.3.0')).toThrow();
    // no importing 0.2.0 games into 0.1.0 either
    expect(() => session._validateSaveVersion('0.2.0', '0.1.30')).toThrow();
    expect(() => session._validateSaveVersion('0.3.0', '0.2.30')).toThrow();

    expect(() => session._validateSaveVersion('0.2.30', '0.2.0')).not.toThrow();
    expect(() => session._validateSaveVersion('0.2.0', '0.2.0')).not.toThrow();
    expect(() => session._validateSaveVersion('1.0.0', '1.0.0')).not.toThrow();
    // 0.x to 1.0 is not a reset, but no reverse-imports, and 0.1.x's still blacklisted
    expect(() => session._validateSaveVersion('0.9.0', '1.0.0')).not.toThrow();
    expect(() => session._validateSaveVersion('1.0.0', '0.9.0')).toThrow();
    expect(() => session._validateSaveVersion('0.1.0', '1.0.0')).toThrow();
    expect(() => session._validateSaveVersion('1.9.0', '1.0.0')).not.toThrow();
    expect(() => session._validateSaveVersion('1.0.0', '1.9.0')).not.toThrow();
    // major versions after 1.0 aren't resets
    expect(() => session._validateSaveVersion('2.0.0', '1.0.0')).not.toThrow();
    expect(() => session._validateSaveVersion('1.0.0', '2.0.0')).not.toThrow();
    // default version - very old saves.
    expect(() => session._validateSaveVersion(undefined, '0.1.0')).not.toThrow();
    expect(() => session._validateSaveVersion(undefined, '0.2.0')).toThrow();
    // current-version based. Breaks when upgrading versions.
    expect(() => session._validateSaveVersion('0.1.0')).toThrow();
    expect(() => session._validateSaveVersion('0.2.0')).not.toThrow();
    expect(() => session._validateSaveVersion('1.0.0')).not.toThrow();
    expect(() => session._validateSaveVersion(undefined)).toThrow();
    expect(() => session._validateSaveVersion('1.0.0-publictest1')).toThrow();
    expect(() => session._validateSaveVersion('1.0.0-publictest8')).toThrow();
    return expect(() => session._validateSaveVersion('1.0.0-publictest20')).toThrow();
  });

  it('validates the save version on import', inject(function(version) {
    session.state.version.started = '0.0.1';
    let encoded = session._saves();
    expect(() => session._loads(encoded)).toThrow();
    session.state.version.started = '1.0.0';
    encoded = session._saves();
    expect(() => session._loads(encoded)).not.toThrow();
    session.state.version.started = version;
    encoded = session._saves();
    expect(() => session._loads(encoded)).not.toThrow();
    // missing version is assumed to be 0.1.0, but we're past 0.2.0 now
    delete session.state.version;
    encoded = session._saves();
    return expect(() => session._loads(encoded)).toThrow();
  })
  );

  it('validates the format version on import, blocking all publictest imports', inject(function(version) {
    const v02 = 'MC4yLjIy|Q2hlYXRlciA6KAoKN4IglgJiBcIG4AYB0AmEAaEALApgQwCcAXAI3yIEkpZFVpdDTyMQBXAOzCKIE8AHHAGcYoMOzhhBYEgBscWPEQDGuAjxggAjCwC2zWCgCsAZhSmkhgOzbMMwnDwbNAFgCcbpADZDzlkoD2Af7sGggsRDgEBFz+aqEsOOyRAObqsGGYBEICSgCiSQSp8ZhJAB6swum6rER4yYnFIHxZOjV1DVWYeIJKiVLBjQBmWTgAStk4Shq+mBAEwThOliwAjqw4HSAZIEmCRI3JWYqRaxshndhgcIsXWFc4p5vbODrNQpVbLM3+fLj7F8l/BAIO9Gnw8OwiLgBhdwZDoew0LCIVCcMFjGCUQjfMj4Wj2IZGv5rgQdGJqJ9MMTImT2BAkZSQNTSeSMRdmbSIDjGRzyYT2STOZ5GoIAO6EHQyMTJEVEaWREV8SAKi46fyCNYxRoyQIVf6M+Z4FQHMAowRKkEERq9SFgAQgxri82NEFwfysLJWgH+GGMzjJLCkVgy1X+KGNEiKRqtWrwxQqSJpRkxlGR/XbFOQpQ6pLRtqQsUS8UEPh52NEAgVLBllH4Y2q/NEYYPGuQsoVVu1UlJjONvRRqoAX1mxxEID2jBwFJQCE0hgAtAgUPPNJoACoIBDQFAADmgmlcSGMlhQAC0WFkJ8QpxoZ3PF8vVxut7v94fj2eWII8Ndp7OF0uK7rggzjQMeYGeEgLjGOemQ4GAgxgDeBj/g+QEbqB4HGJBS6eLBIDZuqyEgHeAGPsBL57geR4nuew5MnwcrBJUwD0awfCHHgIIsfRE5ynsYBKCxIAkDwACqnD/KAcwLGO2aCQA1pUxglKwOhLOEopiOwakaZgOB2HwghTgAYmABB7DAKDuAgxiDvRoliRxBBcTcrGYPJShKTAdldCoSHXHoBZjnwrCyIJER7No+4oCgmizPMSTRdZzi2R5CjsPUOohtZhieJ4liGLMOAkMGMAuK4eXeM4vEKXa9oALJgDIUqVAgmAkv05ygFeEQUpoSDIGE9lAAAA';
    const v1 = 'MS4wLjA=|Q2hlYXRlciA6KAoKN4IglgJiBcIG4AYB0AmEAaEALApgQwCcAXAI3yIEkpZFVpdDTyMQBXAOzCKIE8AHHAGcYoMOzhhBYEgBscWPEQDGuAjxggAjCwC2zWCgCsAZhSmkhgOzbMMwnDwbNAFgCcbpADZDzlkoD2Af7sGggsRDgEBFz+aqEsOOyRAObqsGGYBEICSgCiSQSp8ZhJAB6swum6rER4yYnFIHxZOjV1DVWYeIJKiVLBjQBmWTgAStk4Shq+mBAEwThOliwAjqw4HSAZIEmCRI3JWYqRaxshndhgcIsXWFc4p5vbODrNQpVbLM3+fLj7F8l/BAIO9Gnw8OwiLgBhdwZDoew0LCIVCcMFjGCUQjfMj4Wj2IZGv5rgQdGJqJ9MMTImT2BAkZSQNTSeSMRdmbSIDjGRzyYT2STOZ5GoIAO6EHQyMTJEVEaWREV8SAKi46fyCNYxRoyQIVf6M+Z4FQHMAowRKkEERq9SFgAQgxri82NEFwfysLJWgH+GGMzjJLCkVgy1X+KGNEiKRqtWrwxQqSJpRkxlGR/XbFOQpQ6pLRtqQsUS8UEPh52NEAgVLBllH4Y2q/NEYYPGuQsoVVu1UlJjONvRRqoAX1mxxEID2jBwFJQCE0hgAtAgUPPNJoACoIBDQFAADmgmlcSGMlhQAC0WFkJ8QpxoZ3PF8vVxut7v94fj2eWII8Ndp7OF0uK7rggzjQMeYGeEgLjGOemQ4GAgxgDeBj/g+QEbqB4HGJBS6eLBIDZuqyEgHeAGPsBL57geR4nuew5MnwcrBJUwD0awfCHHgIIsfRE5ynsYBKCxIAkDwACqnD/KAcwLGO2aCQA1pUxglKwOhLOEopiOwakaZgOB2HwghTgAYmABB7DAKDuAgxiDvRoliRxBBcTcrGYPJShKTAdldCoSHXHoBZjnwrCyIJER7No+4oCgmizPMSTRdZzi2R5CjsPUOohtZhieJ4liGLMOAkMGMAuK4eXeM4vEKXa9oALJgDIUqVAgmAkv05ygFeEQUpoSDIGE9lAAAA';
    const publictestImported = 'MS4wLjAtcHVibGljdGVzdDI3|Q2hlYXRlciA6KAoKN4IglgJiBcIG4AYB0AmEAaEALApgQwCcAXAI3yIEkpZFVpdDTyMQBXAOzCKIE8AHHAGcYoMOzhhBYEgBscWPEQDGuAjxggAjCwC2zWCgCsAZhSmkhgOzbMMwnDwbNAFgCcbpADZDzlkoD2Af7sGggsRDgEBFz+aqEsOOyRAObqsGGYBEICSgCiSQSp8ZhJAB6swum6rER4yYnFIHxZOjV1DVWYeIJKiVLBjQBmWTgAStk4Shq+mBAEwThOliwAjqw4HSAZIEmCRI3JWYqRaxshndhgcIsXWFc4p5vbODrNQpVbLM3+fLj7F8l/BAIO9Gnw8OwiLgBhdwZDoew0LCIVCcMFjGCUQjfMj4Wj2IZGv5rgQdGJqJ9MMTImT2BAkZSQNTSeSMRdmbSIDjGRzyYT2STOZ5GoIAO6EHQyMTJEVEaWREV8SAKi46fyCNYxRoyQIVf6M+Z4FQHMAowRKkEERq9SFgAQgxri82NEFwfysLJWgH+GGMzjJLCkVgy1X+KGNEiKRqtWrwxQqSJpRkxlGR/XbFOQpQ6pLRtqQsUS8UEPh52NEAgVLBllH4Y2q/NEYYPGuQsoVVu1UlJjONvRRqoAX1mxxEID2jBwFJQCE0hgAtAgUPPNJoACoIBDQFAADmgmlcSGMlhQAC0WFkJ8QpxoZ3PF8vVxut7v94fj2eWII8Ndp7OF0uK7rggzjQMeYGeEgLjGOemQ4GAgxgDeBj/g+QEbqB4HGJBS6eLBIDZuqyEgHeAGPsBL57geR4nuew5MnwcrBJUwD0awfCHHgIIsfRE5ynsYBKCxIAkDwACqnD/KAcwLGO2aCQA1pUxglKwOhLOEopiOwakaZgOB2HwghTgAYmABB7DAKDuAgxiDvRoliRxBBcTcrGYPJShKTAdldCoSHXHoBZjnwrCyIJER7No+4oCgmizPMSTRdZzi2R5CjsPUOohtZhieJ4liGLMOAkMGMAuK4eXeM4vEKXa9oALJgDIUqVAgmAkv05ygFeEQUpoSDIGE9lAAAA';
    const publictestCreated = 'MS4wLjAtcHVibGljdGVzdDI3|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';
    const publictestBroken = 'MS4wLjAtcHVibGljdGVzdDI2|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';
    expect(() => session._loads(v02)).not.toThrow();
    expect(() => session._loads(v1)).not.toThrow();
    expect(() => session._loads(publictestCreated)).toThrow();
    expect(() => session._loads(publictestImported)).toThrow();
    return expect(() => session._loads(publictestBroken)).toThrow();
  })
  );

  return it('ignores whitespace', inject(function(version) {
    // this example from https://www.reddit.com/r/swarmsim/comments/3352iu/save_file_doesnt_work_anymore_has_anyone/
    const encoded = `MS4wLjQ4|

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

6xil6mI4z

+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

8Rd4MAVhTgFFpAAA==\
`;
    return expect(() => session._loads(encoded)).not.toThrow();
  })
  );
});
