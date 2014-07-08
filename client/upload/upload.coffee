file = ""
url = ""
deletehash = ""

Template.upload.newSheetModal = ->
  Session.get "newSheetModal"

Template.new_sheet_modal.rendered = ->
  showForm()
  $("#new_sheet_modal").modal("show")
  $("#new_sheet_modal").on "hidden.bs.modal", (e) ->
    Session.set "newSheetModal", false

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
  $("#instruments").tagsinput("removeAll")

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
  $("#genres").tagsinput("removeAll")

AutoForm.hooks
  insertSheetForm:
    before:
      insert: (doc, template) ->        
        doc.url = url
        doc.deletehash = deletehash
        doc.instruments = doc.instruments.replace(",", ", ")
        doc.genres = doc.genres.replace(",", ", ")
        doc
    after:
      insert: (doc, template) ->
        handleTagFields()
        Session.set "fileName", ""
        $("#new_sheet_modal").modal("hide")
        doc

Template.upload.sheets = ->
  data = {}
  data.sheets = Sheets.find
    user: Meteor.userId()
  data

Template.new_sheet_modal.fileName = ->
  Session.get "fileName"

showLoading = () ->
  $("#insertSheetForm").hide()
  $("#loadingMessage").show()

showForm = () ->
  $("#insertSheetForm").show()
  $("#loadingMessage").hide()

Template.upload.events
  "click #new-sheet": (event, template) ->
    Session.set("newSheetModal", true)

  "change #file": (event, template) ->
    file = event.target.files[0]
    Session.set "fileName", file.name

  "click #submit": (event, template) ->
    showLoading()

    formData = new FormData()
    formData.append "image", file

    $.ajax
      url: "https://api.imgur.com/3/upload"
      headers:
        'Authorization': 'Client-ID 9c666f6a3a7c76d'
      data: formData
      cache: false
      contentType: false
      processData: false
      type: "POST"
      success: (data, textStatus, jqXHR) ->
        url = data.data.link
        deletehash = data.data.deletehash
        $("#insertSheetForm").submit()