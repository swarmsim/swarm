# Contributing to Swarm Simulator

## Reporting an Issue?

If something's broken in-game, use the "send feedback" link in-game - it'll attach information that helps debug your problem. Thanks!

## Contributing Code

This is an old and lightly-maintained project. I appreciate the thought behind [pull requests](https://help.github.com/articles/using-pull-requests/), but don't expect much. That said - UI enhancements and bug fixes are more likely to be accepted. Gameplay changes (new units/upgrades, balance changes) are very _unlikely_ to be accepted. If in doubt, talk to @erosson first.

If your PR is accepted, I'll link to your Github user page from the in-game patch notes, and later, an in-game credits page (#347). I'll use your Github username here by default; let me know if you'd rather I use your full name/Reddit handle/etc.

Swarmsim is GPLv3-licensed. I'll ask you to confirm your changes are also GPLv3-licensed before merging them.

## Running Swarmsim and Making Changes

<!-- - [Edit source code online, in Codespaces](https://codespaces.new/swarmsim/swarm) -->
<!-- - [Edit source code online, in Gitpod](https://gitpod.io/#https://github.com/swarmsim/swarm) -->

- [Edit source code locally, in a development container (Docker)](https://code.visualstudio.com/docs/devcontainers/tutorial)

Once you've opened one of those, start the server: `yarn && yarn start`

Run automated tests: `yarn test`

Push changes to your github fork and send me a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork). Swarmsim is one man's hobby project, so I may need a few days to respond. Please nag me if it's been a week or more; thanks!

Once I've merged your changes, they'll automatically be released to https://preprod.swarmsim.com within 10 minutes or so. A "real" release to Kongregate and https://www.swarmsim.com will likely take longer - up to a few days, depending what else is being released.

## Releasing Swarmsim changes

Swarmsim is hosted on netlify, using a continuous deployment model. To release changes, just push them to git, and the robots will release them.

https://preprod.swarmsim.com uses the `master` branch. It's on Netlify at https://app.netlify.com/sites/swarmsim-preprod/overview. It's public but not advertised, so be careful about pushing anything too sensitive there.

https://www.swarmsim.com and https://swarmsim.com use the `production` branch. It's on Netlify at https://app.netlify.com/sites/swarmsim-www/overview. You _should_ add a `changelog.html` entry before pushing here (but that's not enforced).
