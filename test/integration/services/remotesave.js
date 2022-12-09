/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

// TODO broken tests
xdescribe('Service: kongregate integration', function() {

  // load the service's module
  let syncer;
  beforeEach(module('swarmApp'));

  // instantiate service
  let kongregateS3Syncer = (syncer = {});
  const userid = '21627386';
  // you're not supposed to share these, but it's for the game's dev/preview instance on kong, which has never been released
  const game_auth_token = '1dd85395a2291302abdb80e5eeb2ec3a80f594ddaca92fa7606571e5af69e881';

  beforeEach(inject(_kongregateS3Syncer_ => syncer = (kongregateS3Syncer = _kongregateS3Syncer_))
  );

  return it("fetches signed s3 urls", function(done) {
    syncer.policy = null;
    const theexport = 'howdy howdy howdy';
    return syncer.init((function(policy, status) {
      expect(status).toBe('success');
      expect(syncer.policy).not.toBeNull();
      expect(syncer.policy.get).not.toBeNull();
      expect(syncer.policy.post).not.toBeNull();
      expect(syncer.policy.delete).not.toBeNull();
      expect(syncer.fetched).toBeNull();
      return syncer.push((function() {
        expect(syncer.fetched).not.toBeNull();
        expect(syncer.fetched.encoded).toBe(theexport);
        syncer.fetched = null;
        return syncer.fetch(function() {
          expect(syncer.fetched).not.toBeNull();
          expect(syncer.fetched.encoded).toBe(theexport);
          return syncer.clear(function() {
            expect(syncer.fetched).toBeNull();
            syncer.fetched = 'notnull';
            return syncer.fetch(function() {
              expect(syncer.fetched).toBeNull();
              return done();});});});
      }), theexport);
    }), userid, game_auth_token);
  });
});
