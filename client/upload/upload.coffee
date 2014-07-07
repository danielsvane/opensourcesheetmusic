file = ""
url = ""
deletehash = ""

AutoForm.hooks
  insertSheetForm:
    before:
      insert: (doc, template) ->
        doc.url = url
        doc.deletehash = deletehash
        doc
    endSubmit: ->
      Session.set "fileName", ""

Template.upload.sheets = ->
  data = {}
  data.sheets = Sheets.find
    user: Meteor.userId()
  data

Template.upload.fileName = ->
  Session.get "fileName"

disableForm = (disable) ->
  $("#insertSheetForm #title, #artist, #browse, #submit").prop("disabled", disable)

Template.upload.events
  "change #file": (event, template) ->
    file = event.target.files[0]
    Session.set "fileName", file.name

  "click #submit": (event, template) ->
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