Template.sheet_table.updateSheetModal = ->
  Session.get "updateSheetModal"

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

handleTagFields = () ->
  # Handle genres and clear field
  tags = $("#instruments").tagsinput("items")
  for tag in tags
    instrument = Instruments.findOne({name:tag})
    if instrument
      Instruments.update instrument._id,
        $inc:
          weight: 1
    else
      Instruments.insert
        name: tag

  # Handle genres and clear field
  genres = $("#genres").tagsinput("items")
  for tag in genres
    genre = Genres.findOne({name:tag})
    if genre
      Genres.update genre._id,
        $inc:
          weight: 1
    else
      Genres.insert
        name: tag

showLoadingMessage = () ->
  $("#updateSheetForm").hide()
  $("#loadingMessage").show()

hideLoadingMessage = () ->
  $("#updateSheetForm").show()
  $("#loadingMessage").hide()

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

  "click .editSheet": (event, template) ->
    console.log "Clicked sheet #{@._id} for editing"
    Session.set("updatingDoc", @._id)
    Session.set("updateSheetModal", true)

  "click .removeSheet": (event, template) ->
    deletehash = Sheets.findOne(@._id).deletehash
    Sheets.remove @._id
    deleteFromImgur deletehash

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