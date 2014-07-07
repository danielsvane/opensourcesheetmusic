Router.configure
  layoutTemplate: "layout"
  load: ->
    Session.set "search", ""
    Session.set "sortOrder", 1
    Session.set "sortBy", "title"
    GAnalytics.pageview()

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