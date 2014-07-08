@Instruments = new Meteor.Collection "instruments",
  schema:
    name:
      type: String
    weight:
      type: Number
      autoValue: ->
        if @.isInsert
          1