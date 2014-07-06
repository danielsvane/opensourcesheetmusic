Router.configure
  layoutTemplate: "layout"

mustBeSignedIn = (pause) ->
  if !Meteor.user()
    Router.go "home"

Router.onBeforeAction mustBeSignedIn,
  except: ["home"]

Router.map ->
  @.route "home",
    path: "/"
  @.route "upload"
  @.route "starred"