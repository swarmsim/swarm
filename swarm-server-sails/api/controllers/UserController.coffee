 # UserController
 #
 # @description :: Server-side logic for managing Users
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports =
  homepage: (req, res) ->
    res.view 'homepage'
  whoami: (req, res) ->
    res.json req.user ? {}
