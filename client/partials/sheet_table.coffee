Template.sheet_table.sheets = ->
  filter =
    sort: {}
  filter.sort[Session.get("sortBy")] = Session.get("sortOrder")

  search = Session.get("search") or ""

  route = Router.current().route.name
  if route is "upload"
    Sheets.find
      user: Meteor.userId()
      $or: [
        title:
          $regex: search
          $options: "i"
      , artist:
          $regex: search
          $options: "i"
      ]
    , filter
  else if route is "starred"
    user = Meteor.users.findOne(Meteor.userId())
    if user and user.stars
      Sheets.find
        _id:
          $in: user.stars
        $or: [
          title:
            $regex: search
            $options: "i"
        , artist:
            $regex: search
            $options: "i"
        ]
      , filter
  else
    Sheets.find
      $or: [
        title:
          $regex: search
          $options: "i"
      , artist:
          $regex: search
          $options: "i"
      ]
    , filter

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

  "keyup #search": (event, template) ->
    Session.set "search", event.currentTarget.value

  "click th a": (event, template) ->
    if Session.get("sortBy") is $(event.currentTarget).attr("data-sort")
      Session.set "sortOrder", Session.get("sortOrder")*-1
    else
      Session.set "sortBy", $(event.currentTarget).attr("data-sort")

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