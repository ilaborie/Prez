(function() {
  var $doc, Prez, Slide, tick,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $doc = $(document);

  tick = function(func) {
    return setInterval(func, 1000);
  };


  /*
    Slide
    Handle slide behaviour (state, steps, ...)
   */

  Slide = (function() {
    var $step;

    $step = null;

    function Slide(num, elt) {
      this.num = num;
      this.setNext = __bind(this.setNext, this);
      this.setCurrent = __bind(this.setCurrent, this);
      this.setPrevious = __bind(this.setPrevious, this);
      this.hide = __bind(this.hide, this);
      this.previousStep = __bind(this.previousStep, this);
      this.nextStep = __bind(this.nextStep, this);
      this.$elt = $(elt);
      this.name = this.$elt.find("h1, h2, h3, h4").first().text();
      $step = this.$elt.find(".step.current");
    }

    Slide.prototype.nextStep = function() {
      if ($step != null) {
        $step.removeClass("current").addClass("done");
      }
      $step = this.$elt.find(".step").not(".done, .current").first();
      if ($step != null) {
        $step.addClass("current");
      }
      if ($step != null) {
        return $step.length > 0;
      } else {
        return false;
      }
    };

    Slide.prototype.previousStep = function() {
      $step.removeClass("current");
      $step = this.$elt.find(".step.done").last();
      if ($step != null) {
        $step.removeClass("done").addClass("current");
      }
      if ($step != null) {
        return $step.length > 0;
      } else {
        return false;
      }
    };

    Slide.prototype.hide = function() {
      this.$elt.find(".step").removeClass("current done");
      return this.$elt.removeClass("previous current next");
    };

    Slide.prototype.setPrevious = function() {
      this.$elt.find(".step").removeClass("current").addClass("done");
      return this.$elt.removeClass("current next").addClass("previous");
    };

    Slide.prototype.setCurrent = function(reverse) {
      this.$elt.removeClass("previous next").addClass("current");
      if (reverse != null) {
        this.$elt.find(".step").addClass("done");
        return this.previousStep();
      } else {
        return this.nextStep();
      }
    };

    Slide.prototype.setNext = function() {
      this.$elt.find(".step").removeClass("done current");
      return this.$elt.removeClass("previous current").addClass("next");
    };

    return Slide;

  })();


  /*
    Prez
    Handle global behaviour (moves, ...)
   */

  Prez = (function() {
    var $allSlides, position, slides, twin;

    $allSlides = [];

    slides = [];

    position = -1;

    twin = null;

    function Prez() {
      this.handleKeyDown = __bind(this.handleKeyDown, this);
      this.last = __bind(this.last, this);
      this.next = __bind(this.next, this);
      this.prev = __bind(this.prev, this);
      this.home = __bind(this.home, this);
      this.moveTo = __bind(this.moveTo, this);
      var i, slide, _i, _len;
      $allSlides = $(".slide");
      for (i = _i = 0, _len = $allSlides.length; _i < _len; i = ++_i) {
        slide = $allSlides[i];
        slides.push(new Slide(i, slide));
      }
      $doc.on("keydown", this.handleKeyDown);
    }

    Prez.prototype.moveTo = function(index, reverse) {
      var slide, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      if (twin != null) {
        if ((_ref = twin.prez) != null) {
          _ref.moveTo(index, reverse);
        }
      }
      if ((index !== position) && (index >= 0) && (index < slides.length)) {
        if ((_ref1 = slides[position - 1]) != null) {
          _ref1.hide();
        }
        if ((_ref2 = slides[position]) != null) {
          _ref2.hide();
        }
        if ((_ref3 = slides[position + 1]) != null) {
          _ref3.hide();
        }
        if ((_ref4 = slides[index - 1]) != null) {
          _ref4.setPrevious();
        }
        if ((_ref5 = slides[index + 1]) != null) {
          _ref5.setNext();
        }
        slide = slides[index];
        if (slide != null) {
          slide.setCurrent(reverse);
          position = index;
          $doc.trigger("slide", [slide, slides.length]);
          document.location.hash = "\#" + (slide.num + 1);
        }
        return slide;
      }
    };

    Prez.prototype.home = function() {
      $allSlides.removeClass("previous current next");
      return this.moveTo(0);
    };

    Prez.prototype.prev = function() {
      return this.moveTo(position - 1, true);
    };

    Prez.prototype.next = function() {
      return this.moveTo(position + 1);
    };

    Prez.prototype.last = function() {
      $allSlides.removeClass("previous current next");
      return this.moveTo(slides.length - 1);
    };

    Prez.prototype.stepOver = function() {
      var slide, _ref;
      if (twin != null) {
        if ((_ref = twin.prez) != null) {
          _ref.stepOver();
        }
      }
      slide = slides[position];
      if (!slide.nextStep()) {
        return this.next();
      }
    };

    Prez.prototype.stepBack = function() {
      var slide, _ref;
      if (twin != null) {
        if ((_ref = twin.prez) != null) {
          _ref.stepBack();
        }
      }
      slide = slides[position];
      if (!slide.previousStep()) {
        return this.prev();
      }
    };

    Prez.prototype.setPresenter = function() {
      var $clock, $now, $time, start, url;
      $("body").addClass("presenter");
      start = moment();
      $clock = $("#clock");
      $now = $clock.find(".now");
      $time = $clock.find(".time");
      tick(function() {
        var diff, now;
        now = moment();
        $now.html(now.format("HH:mm"));
        diff = now.diff(start);
        return $time.html(moment(diff).format("mm:ss"));
      });
      url = document.location.toString();
      return twin = window.open(url, "_blank");
    };

    Prez.prototype.handleKeyDown = function(event) {
      switch (event.keyCode) {
        case 32:
          this.stepOver();
          break;
        case 33:
          this.prev();
          break;
        case 34:
          this.next();
          break;
        case 35:
          this.last();
          break;
        case 36:
          this.home();
          break;
        case 37:
          this.stepBack();
          break;
        case 38:
          this.stepBack();
          break;
        case 39:
          this.stepOver();
          break;
        case 40:
          this.stepOver();
      }
      if ((event.ctrlKey || event.shiftKey) && !event.altKey) {
        switch (event.keyCode) {
          case 80:
            return this.setPresenter();
        }
      }
    };

    return Prez;

  })();


  /*
    Intialization
   */

  $(function() {
    var $pages, handleHash;
    this.prez = new Prez();
    $pages = $("#pages");
    $doc.on("slide", function(event, slide, size) {
      return $pages.html("" + (slide.num + 1) + " / " + size);
    });
    handleHash = function() {
      var page;
      page = location.hash.substr(1) | 0;
      return this.prez.moveTo(page - 1);
    };
    $(this).on("hashchange", handleHash);
    return handleHash();
  });

}).call(this);
