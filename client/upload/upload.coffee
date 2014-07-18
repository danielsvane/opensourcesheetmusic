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

  enableTagsInput("#instruments", Instruments.find().fetch().map (it) -> it.name)
  enableTagsInput("#genres", Genres.find().fetch().map (it) -> it.name)

AutoForm.hooks
  insertSheetForm:
    before:
      insert: (doc, template) ->
        doc.url = url
        doc.deletehash = deletehash
        doc
    after:
      insert: (doc, template) ->
        handleTagFields()
        Session.set "fileName", ""
        $("#new_sheet_modal").modal("hide")

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