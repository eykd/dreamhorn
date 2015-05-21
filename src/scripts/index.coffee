# Dreamhorn
# =========
#
# This is the annotated source for Dreamhorn, a platform for choice-based
# interactive fiction, inspired by [Undum][undum], [Raconteur][raconteur], and
# others. You will find
#
# [undum]: http://undum.com/
# [raconteur]: http://raconteur.readthedocs.org/en/latest/
#
#
# Table of Contents
# -----------------
#
# 1.  [Introduction](./index.html): *In which we make introductions and philosophy*
#     - [Design Philosophy](#section-5)
#     - [Installation](#section-6)
#     - [Preamble](#section-10)
# 2.  [The Dreamhorn Library](./dreamhorn.html): *In which we get down to brass tacks*
# 3.  [The Cloak of Darkness](./main.html): *In which we demonstrate usage by example, and reacquaint with an old friend*
#
# Appendices
# ----------
#
# -   [Effects](./effects.html): *In which we examine the smoke and the mirrors under the light of day*
# -   [Configuration](./config.html): *In which we examine our many options and meditate on the consequences of choice and inaction*
#
#
# Design Philosophy
# -----------------
#
# Like Raconteur, Dreamhorn adheres to [two core principles][philosophy]:
#
# [philosophy]: http://raconteur.readthedocs.org/en/latest/philosophy/
#
# 1. Code should disappear when it doesn't matter
# 2. Interfaces should start simple and become complex as necessary
#
# Dreamhorn is not a port of Undum/Raconteur, but rather a spiritual
# descendant. I did not consult the code, only the behavior, while adding some
# ideas of my own from previous prototypes.
#
#
# Installation
# ------------
#
# Because we are using fancy tools like [Coffeescript][coffee], Dreamhorn will require some
# extra tooling and hand-holding to get started. Once you've written your piece
# though, you can publish it as pure static HTML/CSS/Javascript.
#
# [coffee]: http://coffeescript.org/
#
# For Writing:
# ------------
#
# 1. Install npm
# 2. Install our requirements
# 3. Start the dev server
#
#
# For Publishing:
# ---------------
#
# 1. Build the `dist` files for distribution
# 2. Put them somewhere!
#
#
# Browserify & CommonJS
# ---------------------
#
# This file comprises the main entry point for
# [Browserify][browserify]. Browserify gives us the ability to use
# [CommonJS][commonjs]-style modules.
#
# [browserify]: http://browserify.org/
# [commonjs]: http://www.commonjs.org/
#
# In CommonJS modules, we can `require` a module by name. Third-party libraries
# are available as absolute path names:
#
#     require('jquery')
#
# Our local modules are available as relative path names:
#
#     require('./dreamhorn')
#
# Note that we can leave off the file extension, as we have configured Browserify
# to accept both Javascript (`.js`) and Coffeescript (`.coffee`) files
# interchangeably. Coffeescript files (like this one) are transpiled into
# Javascript by our build file.
#
# Preamble
# --------
#
# At this point, we introduce our first lines of code, mostly simple matters of
# husekeeping. First things first, we must ensure that [jQuery][jquery] is available as a
# global object. Some code that we will require later depends upon jQuery being
# ready and available globally.
#
# [jquery]: http://jquery.com/
$ = window.$ = window.jQuery = require('jquery')

# Next, we have [VelocityJS][velocityjs], a very fast animation suite that also
# works as a jQuery plugin, along with the [Velocity UI Pack][uipack].
#
# [velocityjs]: http://velocityjs.org
# [uipack]: http://julian.com/research/velocity/#uiPack
require('velocity-animate')
require('velocity-ui-pack')

# Quite a bit of Dreamhorn is configurable. Here we require the main
# configuration object. We'll be making use of this shortly, but if you have any
# questions, you may find them answered in the [annotated source](./config.html).
config = require('./game/config')


# Finally! Dreamhorn itself! Marvel in its beauty!
#
dreamhorn = require('./dreamhorn')

# We'll also want to get fancy with some effectual motion design and spiffy animations:
#
require('./game/effects')

# Anyway. Last, but certainly not least, we'll require our main content file,
# which will really make for some exciting times very shortly. Be sure to check
# out the [annotated source](./main.html).
require('./game/main')


# Now that we've taken care of our requirements, we will use a little [jQuery
# trick][ready] to wait until the web browser has gotten the page ready. Once the
# page is ready, we're going to find the `#main` element on the page and pass
# that, along with our configuration to `dreamhorn.init()`. This will tell
# Dreamhorn to get ready to do its thing.
#
# [ready]: http://learn.jquery.com/using-jquery-core/document-ready/
$ ->
  config.el = $('#main').get(0)
  dreamhorn.init config

# At this point, we've run out of things to do. Next, you should read [The
# Dreamhorn Library](./dreamhorn.html) and see what you can learn there.
