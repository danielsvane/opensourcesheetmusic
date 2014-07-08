@Sheets = new Meteor.Collection "sheets",
  schema:
    title:
      type: String
    artist:
      type: String
    stars:
      type: Number
      defaultValue: 0
    difficulty:
      type: Number
      min: 1
      max: 5
      defaultValue: 1
    instruments:
      type: String
      optional: true
    genres:
      type: String
      optional: true
    url:
      type: String
    deletehash:
      type: String
    created:
      type: Number
      autoValue: ->
        moment().unix()
    user:
      type: String
      autoValue: ->
        if @.isInsert
          @.userId