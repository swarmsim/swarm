assert = require('assert');

describe.only('hello js', function() {
  it('runs the test', function (done) {
    done()
  });
  it('fails the test', function (done) {
    assert.ok(false);
    done();
  });
  it('breaks the test', function (done) {
    throw new Error('howdy');
  });
});
