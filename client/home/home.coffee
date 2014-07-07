Template.home.sheets = ->
  data = {}
  if !Session.get("search")
    data.sheets = Sheets.find()
  else
    data.sheets = Sheets.find
      $or: [
        title:
          $regex: Session.get("search")
          $options: "i"
      , artist:
          $regex: Session.get("search")
          $options: "i"
      ]
  data

Template.home.events
  "keyup #search": (event, template) ->
    Session.set "search", event.currentTarget.value