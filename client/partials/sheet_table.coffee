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
    deletehash = Sheets.findOne(@._id).deletehash
    Sheets.remove @._id
    # $.ajax
    #   url: "https://api.imgur.com/3/image/#{deletehash}"
    #   headers:
    #     'Authorization': 'Client-ID 9c666f6a3a7c76d'
    #   cache: false
    #   contentType: false
    #   processData: false
    #   type: "DELETE"

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