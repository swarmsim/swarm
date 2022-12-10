'use strict'

# TODO broken tests
xdescribe 'Service: kongregate integration', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  kongregateS3Syncer = syncer = {}
  userid = '21627386'
  # you're not supposed to share these, but it's for the game's dev/preview instance on kong, which has never been released
  game_auth_token = '1dd85395a2291302abdb80e5eeb2ec3a80f594ddaca92fa7606571e5af69e881'

  beforeEach inject (_kongregateS3Syncer_) ->
    syncer = kongregateS3Syncer = _kongregateS3Syncer_

  it "fetches signed s3 urls", (done) ->
    syncer.policy = null
    theexport = 'howdy howdy howdy'
    syncer.init ((policy, status) ->
      expect(status).toBe 'success'
      expect(syncer.policy).not.toBeNull()
      expect(syncer.policy.get).not.toBeNull()
      expect(syncer.policy.post).not.toBeNull()
      expect(syncer.policy.delete).not.toBeNull()
      expect(syncer.fetched).toBeNull()
      syncer.push (->
        expect(syncer.fetched).not.toBeNull()
        expect(syncer.fetched.encoded).toBe theexport
        syncer.fetched = null
        syncer.fetch ->
          expect(syncer.fetched).not.toBeNull()
          expect(syncer.fetched.encoded).toBe theexport
          syncer.clear ->
            expect(syncer.fetched).toBeNull()
            syncer.fetched = 'notnull'
            syncer.fetch ->
              expect(syncer.fetched).toBeNull()
              done()
      ), theexport
    ), userid, game_auth_token
