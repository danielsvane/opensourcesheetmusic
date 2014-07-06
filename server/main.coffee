Meteor.publish "sheets", ->
  Sheets.find()

Sheets.allow
  insert: (userId, doc) ->
    userId
  update: (userId, doc) ->
    userId
  remove: (userId, doc) ->
    userId is doc.user

Meteor.publish "users", ->
  Meteor.users.find @.userId,
    fields:
      stars: 1

Meteor.users.allow
  update: ->
    true