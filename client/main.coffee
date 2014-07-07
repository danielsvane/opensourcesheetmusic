SimpleSchema.debug = true

Meteor.subscribe("users")
Meteor.subscribe("sheets")

Meteor.users.find({ "status.online": true }).observe
  added: (user) ->
    Meteor.call "saveIp", user