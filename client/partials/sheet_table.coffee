Template.sheet_table.isOwner = ->
  @.user is Meteor.userId()

Template.sheet_table.starred = ->
  user = Meteor.users.findOne(Meteor.userId())
  if user and user.stars
    stars = user.stars
    if stars.indexOf(@._id) is -1
      false
    else
      true

Template.sheet_table.notCreatedByUser = ->
  @.user isnt Meteor.userId()

Template.sheet_table.events
  "click .removeSheet": (event, template) ->
    Sheets.remove @._id

  "click .star": (event, template) ->
    Sheets.update @._id,
      $inc:
        stars: 1
    Meteor.users.update Meteor.userId(),
      $addToSet:
        stars: @._id

  "click .unstar": (event, template) ->
    Sheets.update @._id,
      $inc:
        stars: -1
    Meteor.users.update Meteor.userId(),
      $pull:
        stars: @._id