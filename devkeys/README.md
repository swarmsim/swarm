### "Oh no! There is a private key in your github repository!"

It's safe. The key is only used for testing SSL in development. It's never used in production. (Probably a bad habit to commit it anyway, though.)

https://github.com/erosson/swarm/pull/319#discussion_r24644335

### What's swarmsim-preprod.pem.enc?

It's used by travis-ci to automatically push all changes to https://preprod.swarmsim.com . It's encrypted by travis-ci; can't use it to deploy preprod yourself. Docs talk about using github oauth instead of deploy keys, but github oauth grants access to *all* repositories, including swarmsim-prod - scary! Deploy keys only grant a single repo.

http://docs.travis-ci.com/user/encrypting-files/

http://docs.travis-ci.com/user/deployment/releases/

http://stackoverflow.com/questions/23277391/pushing-to-github-from-travis-ci

https://medium.com/@nthgergo/publishing-gh-pages-with-travis-ci-53a8270e87db
