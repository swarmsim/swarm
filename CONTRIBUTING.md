# Contributing to Swarm Simulator

## Reporting an Issue?

If something's broken in-game, use the "send feedback" link in-game - it'll attach information that helps debug your problem. Thanks!

## Contributing Code

[Pull requests](https://help.github.com/articles/using-pull-requests/) are awesome. UI enhancements and bug fixes are very likely to be accepted. Gameplay changes (new units/upgrades, balance changes) are very *unlikely* to be accepted. If in doubt, talk to @erosson first.

If your PR is accepted, I'll link to your Github user page from the in-game patch notes, and later, an in-game credits page (#347). I'll use your Github username here by default; let me know if you'd rather I use your full name/Reddit handle/etc.

Swarmsim is GPLv2-licensed. I'll ask you to confirm your changes are also GPLv2-licensed before merging them.

Swarmsim's developed on an Ubuntu Linux machine. I've heard http://c9.io works with some tweaking, too.

## Running Swarmsim and Making Changes

* [Fork](https://help.github.com/articles/fork-a-repo/) and clone the repository: `git clone git@github.com:your-username/swarm.git`
* Install dependencies: `./install.sh`
  * If the install script breaks on your machine, [file an issue](https://github.com/swarmsim/swarm/issues/new), or - even better - send me a PR fixing the problem.
* Run the server: `grunt serve`
* Make your changes. Game's running at http://localhost:9000 , and reloads whenever you change something.
* Run automated tests: `grunt test` , or edit a file in `test/` while `grunt serve` is running. Tests must pass before I merge your PR.
* Push changes to your fork and send me a pull request. Swarmsim is one man's hobby project, so I may need a few days to respond. Please nag me if it's been a week or more. Thanks!

Once I've merged your changes, they'll automatically be released to https://preprod.swarmsim.com within 10 minutes or so. A "real" release to Kongregate and https://swarmsim.github.com will likely take longer - up to a few days, depending what else is being released.
