# function from typeahead.js example
substringMatcher = (strs) ->
  findMatches = (q, cb) ->
    matches = undefined
    substringRegex = undefined
    # an array that will be populated with substring matches
    matches = []
    # regex used to determine if a string contains the substring `q`
    substrRegex = new RegExp(q, "i")
    # iterate through the pool of strings and for any string that
    # contains the substring `q`, add it to the `matches` array
    $.each strs, (i, str) ->
      # the typeahead jQuery plugin expects suggestions to a
      # JavaScript object, refer to typeahead docs for more info
      matches.push value: str  if substrRegex.test(str)
    cb matches

@enableTagsInput = (input, data) ->
  tags = $("#{input}")
  tags.tagsinput()
  $(tags).each (i, o) ->
    
    # grab the input inside of tagsinput
    taginput = $(o).tagsinput("input")
    
    # initialize typeahead for the tag input
    taginput.typeahead(
      hint: false
      highlight: true
      minLength: 1
      autoselect: true
    ,
      name: "states"
      displayKey: "value"
      source: substringMatcher(data)
    ).bind "typeahead:selected", $.proxy((obj, datum) ->
      # if the state is clicked, add it to tagsinput and clear input
      $(o).tagsinput "add", datum.value
      taginput.typeahead "val", ""
    )
  
    # erase any entered text on blur
    $(taginput).blur ->
      taginput.typeahead "val", ""

@deleteFromImgur = (deletehash) ->
  $.ajax
    url: "https://api.imgur.com/3/image/#{deletehash}"
    headers:
      'Authorization': 'Client-ID 9c666f6a3a7c76d'
    cache: false
    contentType: false
    processData: false
    type: "DELETE"
    success: (data, textStatus, jqXHR) ->
      console.log textStatus

@handleTagFields = () ->
  # Handle instruments and clear field
  tags = $("#instruments").tagsinput("items")
  for tag in tags
    tag = tag
    console.log tag
    instrument = Instruments.findOne({name:tag})
    if instrument
      Instruments.update instrument._id,
        $inc:
          weight: 1
    else
      Instruments.insert
        name: tag

  # Handle genres and clear field
  genres = $("#genres").tagsinput("items")
  for tag in genres
    genre = Genres.findOne({name:tag})
    if genre
      Genres.update genre._id,
        $inc:
          weight: 1
    else
      Genres.insert
        name: tag