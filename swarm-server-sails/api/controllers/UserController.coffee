 # UserController
 #
 # @description :: Server-side logic for managing Users
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports =
  homepage: (req, res) ->
    res.view 'homepage'
  whoami: (req, res) ->
    if not req.user?.id?
      return res.json {}, 404
    console.log req.user
    User.findOne(req.user.id).populate('characters').exec (err, user) ->
      if err
        return res.render {error:true, message:err}, 500
      if not user
        return res.json {}, 404
      return res.json user
