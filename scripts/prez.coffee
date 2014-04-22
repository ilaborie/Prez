# Prez require a modern browser and Zepto.js
$doc = $(document)

# Every second
tick = (func) ->
  setInterval func, 1000

###
  Slide
  Handle slide behaviour (state, steps, ...)
###
class Slide
  # private attributes
  $step = null
  constructor: (@num, elt) ->
    @$elt = $(elt)
    @name = @$elt.find("h1, h2, h3, h4").first().text()
    $step = @$elt.find ".step.current"
  # Step
  nextStep: () =>
    $step?.removeClass("current").addClass "done"
    $step = @$elt.find(".step").not(".done, .current").first()
    $step?.addClass "current"
    if $step? then $step.length > 0 else false
  previousStep: () =>
    $step.removeClass "current"
    $step = @$elt.find(".step.done").last()
    $step?.removeClass("done").addClass "current"
    if $step? then $step.length > 0 else false
  # set states
  hide: () =>
    @$elt.find(".step").removeClass "current done"
    @$elt.removeClass "previous current next"
  setPrevious: () =>
    @$elt.find(".step").removeClass("current").addClass "done"
    @$elt.removeClass("current next").addClass "previous"
  setCurrent: (reverse)  =>
    @$elt.removeClass("previous next").addClass "current"
    if reverse?
      @$elt.find(".step").addClass "done"
      @previousStep()
    else @nextStep()
  setNext: ()     =>
    @$elt.find(".step").removeClass("done current")
    @$elt.removeClass("previous current").addClass "next"

###
  Prez
  Handle global behaviour (moves, ...)
###
class Prez
  # private attributes
  $allSlides = []
  slides = []
  position = -1
  twin = null

  # Constructor
  constructor: () ->
    $allSlides = $(".slide")
    for slide, i in $allSlides
      slides.push new Slide(i, slide)
    $doc.on "keydown", @handleKeyDown
    if Hammer?
      # Touch events
      Hammer(document).on "tap", () =>
        @stepOver()
      Hammer(document).on "doubletap", () =>
        @stepBack()
      # Swipe events
      Hammer(document).on "swipeup", () =>
        @home()
      Hammer(document).on "swipeleft", () =>
        @next()
      Hammer(document).on "swiperight", () =>
        @prev()
      Hammer(document).on "swipedown", () =>
        @last()

  # Move to a specific slide
  moveTo: (index, reverse) =>
    twin?.prez?.moveTo index, reverse
    if (index isnt position) and (index >= 0) and (index < slides.length)
      slides[position - 1]?.hide()
      slides[position]?.hide()
      slides[position + 1]?.hide()
      slides[index - 1]?.setPrevious()
      slides[index + 1]?.setNext()
      slide = slides[index]
      if slide?
        slide.setCurrent(reverse)
        position = index
        $doc.trigger "slide", [slide, slides.length]
        document.location.hash = "\##{slide.num + 1}"
      slide

  # Other moves
  home: () =>
    $allSlides.removeClass "previous current next"
    @moveTo 0
  prev: () =>
    @moveTo (position - 1), true
  next: () =>
    @moveTo (position + 1)
  last: () =>
    $allSlides.removeClass "previous current next"
    @moveTo (slides.length - 1)

  # Steps
  stepOver: () ->
    twin?.prez?.stepOver()
    slide = slides[position]
    unless slide.nextStep() then @next()
  stepBack: () ->
    twin?.prez?.stepBack()
    slide = slides[position]
    unless slide.previousStep() then @prev()

  # Presenter Mode
  setPresenter: () ->
    $("body").addClass "presenter"
    start = moment()
    $clock = $("#clock")
    $now = $clock.find ".now"
    $time = $clock.find ".time"
    tick () ->
      now = moment()
      $now.html now.format("HH:mm")
      diff = now.diff start
      $time.html moment(diff).format("mm:ss")
    # Open and drive the twin
    url = document.location.toString()
    twin = window.open url, "_blank"

  # Listeners
  handleKeyDown: (event) =>
    switch event.keyCode
      when 32 then @stepOver() # space
      when 33 then @prev() # page up
      when 34 then @next() # page down
      when 35 then @last() # end
      when 36 then @home() # home
      when 37 then @stepBack() # left
      when 38 then @stepBack() # up
      when 39 then @stepOver() # right
      when 40 then @stepOver() # down
      else # do nothing

    if (event.ctrlKey || event.shiftKey) && !event.altKey
      switch event.keyCode
        when 80 then @setPresenter() # Ctrl+P || Shift+P
        else # do nothing

###
  Initialization
###
$ () ->
  @prez = new Prez()

  # Pages
  $pages = $ "#pages"
  $doc.on "slide", (event, slide, size) ->
    $pages.html "#{slide.num + 1} / #{size}"

  # Get the Hash or go Home
  handleHash = () ->
    page = location.hash.substr(1) | 0
    index = if page is 0 then 0 else page - 1
    @prez.moveTo index
  $(this).on "hashchange", handleHash
  handleHash()

