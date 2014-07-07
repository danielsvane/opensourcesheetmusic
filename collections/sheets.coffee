@Sheets = new Meteor.Collection "sheets",
  schema:
    title:
      type: String
    artist:
      type: String
    url:
      type: String
    deletehash:
      type: String
    created:
      type: String
      autoValue: ->
        moment().format("DD-MM-YYYY")
    stars:
      type: Number
      defaultValue: 0
    user:
      type: String
      autoValue: ->
        if @.isInsert
          @.userId

Sheets.allow
  remove: ->
    true