describe 'user', ->
  it 'cruds', (done) ->
    User.find().exec (err, users) ->
      assert.equal 0, users.length
      done()
