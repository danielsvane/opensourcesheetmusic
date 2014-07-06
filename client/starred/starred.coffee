Template.starred.sheets = ->
  user = Meteor.users.findOne(Meteor.userId())
  data = {}
  if user and user.stars
    data.sheets = Sheets.find
      _id:
        $in: user.stars
  data