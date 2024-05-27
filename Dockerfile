# Build a node-based static site
FROM node:16-bullseye AS build

# ugly ruby stuff; this thing is ancient
# https://github.com/rvm/ubuntu_rvm
# https://askubuntu.com/questions/1480616/adding-opencpn-repository-attributeerror-nonetype-object-has-no-attribute
ENV PATH $PATH:/usr/local/rvm/bin
RUN curl -sSL https://get.rvm.io | bash &&\
    . /etc/profile.d/rvm.sh &&\
    rvm --version
WORKDIR /app
COPY .devcontainer/setup/rvm.sh /app/.devcontainer/setup/rvm.sh
# https://github.com/rvm/rvm/issues/4975#issuecomment-1477478096
RUN ln -s /bin/mkdir /usr/bin/mkdir
# RUN .devcontainer/setup/rvm.sh && ruby --version
RUN .devcontainer/setup/rvm.sh
# ENV PATH $PATH:/usr/local/rvm/environments/ruby-2.5.9
RUN . /usr/local/rvm/environments/default && ruby --version && compass --version

COPY package.json yarn.lock /app/
WORKDIR /app/tables/
COPY tables/package.json tables/yarn.lock /app/tables/
WORKDIR /app/swarmsim-ts/
COPY swarmsim-ts/package.json swarmsim-ts/yarn.lock /app/swarmsim-ts/
WORKDIR /app/swarmsim-coffee/
COPY swarmsim-coffee/package.json swarmsim-coffee/yarn.lock /app/swarmsim-coffee/
WORKDIR /app
RUN yarn

# `.dockerignore` is important to cache this copy properly
COPY . /app/
# docker seems upset if bower_components is a symlink, for some reason, so copy the whole thing. Works fine in the devcontainer and in CI. Ugh.
RUN (cd swarmsim-coffee && rm bower_components && cp -rp node_modules/@bower_components bower_components)
# openssl_conf: this fixes tests and build. https://github.com/bazelbuild/rules_closure/issues/351#issuecomment-854628326 . Ugh.
RUN . /usr/local/rvm/environments/default && OPENSSL_CONF=/dev/null yarn test
# `yarn build` includes an application-level ssl redirect. docker doesn't want that!
RUN . /usr/local/rvm/environments/default && OPENSSL_CONF=/dev/null yarn build:docker

# Run the static site we just built. No Caddyfile or other config, just static files.
# "The default config file simply serves files from /usr/share/caddy" - https://hub.docker.com/_/caddy
FROM caddy:2.8
COPY --from=build /app/dist/ /usr/share/caddy