'use strict'

exports.up = (knex, Promise) ->
  #knex.schema.createTable ...
  # pasted here from pgAdmin gui (but that won't work for updates after the first)
  knex.raw """
CREATE TABLE "user"
(
  username text,
  email text,
  id serial NOT NULL,
  "createdAt" timestamp with time zone NOT NULL,
  "updatedAt" timestamp with time zone NOT NULL,
  CONSTRAINT user_pkey PRIMARY KEY (id),
  CONSTRAINT user_email_key UNIQUE (email),
  CONSTRAINT user_username_key UNIQUE (username)
);

CREATE TABLE character
(
  "user" integer NOT NULL,
  name text NOT NULL,
  state jsonb NOT NULL,
  deleted boolean NOT NULL,
  source text NOT NULL,
  id serial NOT NULL,
  "createdAt" timestamp with time zone NOT NULL,
  "updatedAt" timestamp with time zone NOT NULL,
  CONSTRAINT character_pkey PRIMARY KEY (id)
);

CREATE TABLE passport
(
  protocol text,
  password text,
  "accessToken" text,
  provider text,
  identifier text,
  tokens json,
  "user" integer NOT NULL,
  id serial NOT NULL,
  "createdAt" timestamp with time zone NOT NULL,
  "updatedAt" timestamp with time zone NOT NULL,
  CONSTRAINT passport_pkey PRIMARY KEY (id)
)
"""
  
exports.down = (knex, Promise) ->
  knex.schema.dropTable 'passport'
  knex.schema.dropTable 'character'
  knex.schema.dropTable 'user'
