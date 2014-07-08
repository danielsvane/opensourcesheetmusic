UI.registerHelper "formatDate", (time) ->
  moment(time, "X").format("DD-MM-YYYY")