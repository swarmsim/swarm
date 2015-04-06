# swarm-server-sails

a [Sails](http://sailsjs.org) application

Used for Kongregate online saves. Previously used a Rails server, https://github.com/swarmsim/swarm-server

If you're contributing, you probably don't need to change this.

* run tests once: `npm test`
* watch, re-running tests on change: `mocha --watch`
* serve: `KONGREGATE_API_KEY=43e67f20-cd11-47cb-a5a8-e5cd07123273 AWS_REGION='us-east-1' AWS_ACCESS_KEY_ID=AKIAJTBY35U6XOKYT57A AWS_SECRET_ACCESS_KEY=... BUCKET=swarmsim-dev node_modules/forever/bin/forever -w app.js`
* update dev deploy config: `eb setenv -e swarm-server-sails-dev KONGREGATE_API_KEY=...`
* deploy dev: `eb deploy swarm-server-sails-dev`
* deploy prod: `eb deploy swarm-server-sails-prod`
