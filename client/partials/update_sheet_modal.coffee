file = undefined
url = ""
deletehash = ""

AutoForm.hooks
  updateSheetForm:
    before:
      update: (id, docType, template) ->
        doc = docType.$set
        doc.instruments = doc.instruments.replace(",", ", ")
        doc.genres = doc.genres.replace(",", ", ")
        if file
          doc.url = url
          doc.deletehash = deletehash
        docType.$set = doc
        docType
    after:
      update: (doc, template) ->
        handleTagFields()
        Session.set "fileName", ""
        $("#update_sheet_modal").modal("hide")
    onError: (operation) ->
      hideLoadingMessage()

Template.update_sheet_modal.fileName = ->
  Session.get "fileName"

Template.update_sheet_modal.rendered = ->
  hideLoadingMessage()
  $("#update_sheet_modal").modal("show")
  $("#update_sheet_modal").on "hidden.bs.modal", (e) ->
    Session.set "updateSheetModal", false

  enableTagsInput("#instruments", Instruments.find().fetch().map (it) -> it.name)
  enableTagsInput("#genres", Genres.find().fetch().map (it) -> it.name)

showLoadingMessage = () ->
  $("#updateSheetForm").hide()
  $("#loadingMessage").show()

hideLoadingMessage = () ->
  $("#updateSheetForm").show()
  $("#loadingMessage").hide()

Template.update_sheet_modal.updatingDoc = ->
  Sheets.findOne(Session.get("updatingDoc"))

Template.update_sheet_modal.events
  "change #file": (event, template) ->
    file = event.target.files[0]
    Session.set "fileName", file.name

  "click #submit": (event, template) ->
    showLoadingMessage()

    if file
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
          deleteFromImgur deletehash
          $("#updateSheetForm").submit()
    else
      $("#updateSheetForm").submit()