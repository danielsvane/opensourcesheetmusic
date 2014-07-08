UI.registerHelper "formatDate", (time) ->
  moment(time, "X").format("DD-MM-YYYY")

UI.registerHelper "formatTags", (tags) ->
  tags.replace(/,/g, ", ")