@Genres = new Meteor.Collection "genres",
  schema:
    name:
      type: String
    weight:
      type: Number
      autoValue: ->
        if @.isInsert
          1