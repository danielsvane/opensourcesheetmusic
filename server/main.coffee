Meteor.publish "sheets", ->
  Sheets.find()

Meteor.publish null, ->
  Meteor.roles.find()

Sheets.allow
  insert: (userId, doc) ->
    userId
  update: (userId, doc) ->
    userId
  remove: (userId, doc) ->
    (userId is doc.user) or Roles.userIsInRole(userId, ["admin"])

Meteor.publish "users", ->
  Meteor.users.find @.userId,
    fields:
      stars: 1
      status: 1

Meteor.users.allow
  update: ->
    true

Meteor.methods
  saveIp: (user) ->
    ip = UserStatus.connections.findOne({userId: user._id}).ipAddr
    Meteor.users.update user._id,
      $addToSet:
        ips: ip
    ip