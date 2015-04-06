 # PoliciesController
 #
 # @description :: Server-side logic for managing policies
 # @help        :: See http://links.sailsjs.org/docs/controllers

aws = require 'aws-sdk'
https = require 'https'
crypto = require 'crypto'
querystring = require 'querystring'
moment = require 'moment'

SECRETS =
  KONGREGATE_API_KEY: process.env.KONGREGATE_API_KEY
  AWS_REGION: process.env.AWS_REGION
  AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY
  BUCKET: process.env.BUCKET

textResponse = (res, callback) ->
  body = ''
  res.on 'data', (chunk) ->
    body += chunk
  res.on 'end', ->
    callback body

jsonResponse = (res, callback) ->
  textResponse res, (body, res) ->
    callback JSON.parse body

module.exports =
  create: (req, res) ->
    req.checkBody('policy.user_id').notEmpty().isInt()
    req.checkBody('policy.game_auth_token').notEmpty()
    if (errors=req.validationErrors())
      res.send JSON.stringify(errors:errors), 400
      return
    policy = req.body.policy
    kong_args = {user_id:policy.user_id, game_auth_token:policy.game_auth_token, api_key:SECRETS.KONGREGATE_API_KEY}
    kong_url = "https://api.kongregate.com/api/authenticate.json?#{querystring.stringify kong_args}"
    #sails.log 'requesting', kong_url
    https.get kong_url, (kongres) ->
      jsonResponse kongres, (kongjson) ->
        if kongjson.success
          # valid user!
          #res.send "howdy from policies.create #{res.statusCode} #{JSON.stringify kongjson}"
          # http://docs.aws.amazon.com/AWSJavaScriptSDK/guide/node-examples.html
          s3 = new aws.S3()
          # TODO hash auth_token? this will go away soon anyway
          key = "saves/#{policy.game_auth_token}_#{policy.user_id}.json"
          expires_in = 60 * 60 * 24 * 1
          expires_date = moment.utc().add expires_in, 'seconds'
          doc =
            expiration: expires_date.toISOString()
            conditions: [
              {bucket: SECRETS.BUCKET}
              {key: key}
              {acl: 'private'}
              {'Content-Type': 'application/json'}
              ['content-length-range', 0, 16384]
            ]
          # signed post policy. http://stackoverflow.com/questions/18476217
          doc64 = Buffer(JSON.stringify(doc), 'utf-8').toString 'base64'
          signature = crypto.createHmac('sha1', SECRETS.AWS_SECRET_ACCESS_KEY).update(new Buffer(doc64, 'utf-8')).digest 'base64'
          # construct response
          ret = {}
          ret.get = s3.getSignedUrl 'getObject', Bucket: SECRETS.BUCKET, Key: key, Expires: expires_in
          ret.delete = s3.getSignedUrl 'deleteObject', Bucket: SECRETS.BUCKET, Key: key, Expires: expires_in
          ret.post =
            url: "https://#{SECRETS.BUCKET}.s3.amazonaws.com"
            params:
              key: key
              AWSAccessKeyId: SECRETS.AWS_ACCESS_KEY_ID
              acl: 'private'
              policy: doc64
              signature: signature
              "Content-type": "application/json"
          ret.expires_in = expires_in
          ret.server_date =
            #refreshed: moment.utc().unix()
            refreshed: moment.utc().valueOf()
            expires: expires_date.valueOf()
          res.type 'json'
          res.send JSON.stringify ret
        else # !kongjson.success; invalid user
          res.status if (400 <= kongjson.error < 500) then 400 else 500
          res.send JSON.stringify kongjson
          return
    .on 'error', (e) ->
      sails.log.error 'kongregate-auth error', e
