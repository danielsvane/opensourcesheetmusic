Template.sheet_table.editSheetModal = ->
  Session.get "editSheetModal"

Template.edit_sheet_modal.rendered = ->
  showForm()
  $("#edit_sheet_modal").modal("show")
  $("#edit_sheet_modal").on "hidden.bs.modal", (e) ->
    Session.set "editSheetModal", false

  # function from typeahead.js example
  substringMatcher = (strs) ->
    findMatches = (q, cb) ->
      matches = undefined
      substringRegex = undefined
      # an array that will be populated with substring matches
      matches = []
      # regex used to determine if a string contains the substring `q`
      substrRegex = new RegExp(q, "i")
      # iterate through the pool of strings and for any string that
      # contains the substring `q`, add it to the `matches` array
      $.each strs, (i, str) ->
        # the typeahead jQuery plugin expects suggestions to a
        # JavaScript object, refer to typeahead docs for more info
        matches.push value: str  if substrRegex.test(str)
      cb matches

  tags = $("#instruments")
  tags.tagsinput()
  $(tags).each (i, o) ->
    
    # grab the input inside of tagsinput
    taginput = $(o).tagsinput("input")
    
    # initialize typeahead for the tag input
    taginput.typeahead(
      hint: false
      highlight: true
      minLength: 1
      autoselect: true
    ,
      name: "states"
      displayKey: "value"
      source: substringMatcher(Instruments.find().fetch().map (it) -> it.name)
    ).bind "typeahead:selected", $.proxy((obj, datum) ->
      # if the state is clicked, add it to tagsinput and clear input
      $(o).tagsinput "add", datum.value
      taginput.typeahead "val", ""
    )
  
    # erase any entered text on blur
    $(taginput).blur ->
      taginput.typeahead "val", ""

  genres = $("#genres")
  genres.tagsinput()
  $(genres).each (i, o) ->
    
    # grab the input inside of tagsinput
    taginput = $(o).tagsinput("input")
    
    # initialize typeahead for the tag input
    taginput.typeahead(
      hint: false
      highlight: true
      minLength: 1
      autoselect: true
    ,
      name: "states"
      displayKey: "value"
      source: substringMatcher(Genres.find().fetch().map (it) -> it.name)
    ).bind "typeahead:selected", $.proxy((obj, datum) ->
      # if the state is clicked, add it to tagsinput and clear input
      $(o).tagsinput "add", datum.value
      taginput.typeahead "val", ""
    )
  
    # erase any entered text on blur
    $(taginput).blur ->
      taginput.typeahead "val", ""

Template.edit_sheet_modal.editingDoc = ->
  Sheets.findOne(Session.get("editingDoc"))

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

AutoForm.hooks
  editSheetForm:
    before:
      update: (id, docType, template) ->
        doc = docType.$set
        doc.instruments = doc.instruments.replace(",", ", ")
        doc.genres = doc.genres.replace(",", ", ")
        docType.$set = doc
        docType
    after:
      update: (doc, template) ->
        handleTagFields()
        $("#edit_sheet_modal").modal("hide")
        doc

showLoading = () ->
  $("#editSheetForm").hide()
  $("#loadingMessage").show()

showForm = () ->
  $("#editSheetForm").show()
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
    Session.set("editingDoc", @._id)
    Session.set("editSheetModal", true)

  "click #submit": (event, template) ->
    showLoading()
    $("#editSheetForm").submit()

  "click .removeSheet": (event, template) ->
    deletehash = Sheets.findOne(@._id).deletehash
    Sheets.remove @._id
    $.ajax
      url: "https://api.imgur.com/3/image/#{deletehash}"
      headers:
        'Authorization': 'Client-ID 9c666f6a3a7c76d'
      cache: false
      contentType: false
      processData: false
      type: "DELETE"
      success: (data, textStatus, jqXHR) ->
        console.log textStatus

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