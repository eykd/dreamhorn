###
Dreamhorn
=========

Dreamhorn is a platform for choice-based interactive fiction, inspired by Undum
and Raconteur.

###

$ = require('jquery')
_ = require('underscore')
Backbone = require('backbone')
markdown = require('markdown-it') 'default',
  html: true
  typographer: true


###

Models & Collections
--------------------

We'll use `Backbone.Model` for storing all story state. We'll use
`Backbone.Collection` for storing collections of models.

###

class Model extends Backbone.Model
  constructor: (data, options) ->
    @dispatcher = options.dispatcher if options
    super data, options



class Collection extends Backbone.Collection
  constructor: (models, options) ->
    @dispatcher = options.dispatcher if options
    super models, options



###

World
-----

The World contains the state of the game world.

###
class World extends Model


###

Items
-----

The Items contains the state of the player inventory.

###
class Items extends Collection


###

Situation
---------

A Situation corresponds to a presentation of text and a choice.

###
class Situation extends Model
  initialize: ->


###

Situations
----------

We'll use `Situations` collection for several purposes: one, a global registry
of available situations; two, a stack of currently-active situations.

###
class Situations extends Collection
  model: Situation


###

Qualitiy
--------

FIXME:Still need to figure out how these will work!

###
class Quality extends Backbone.Model
  initialize: ->

  update: (value) ->
    @set('value', value)


class Qualities extends Backbone.Collection
  model: Quality

  initialize: ->
    that = this
    @options.target.on 'change', (model, options) ->
      changes = model.changedAttributes()
      _.forIn changes, (value, key) ->
        q = that.get(key)
        if q
          q.update(value)


###

Views
-----

`Backbone.View` provides a way to render data to the page, and a way to handle
events generated on the page.

###

class View extends Backbone.View
  initialize: (options) ->
    @options = options
    @dispatcher = options.dispatcher
    super options


###

The Title View
--------------

The Title View presents the title of the piece, and provides the entrypoint
into the first Situation.

###
class TitleView extends View
  tagName: "header"
  className: "title"

  initialize: (options) ->
    super options
    @button_view = new BeginButtonView options.get_options()

  render: ->
    @button_view.render()
    button = $ '<p></p>'
    button.append(@button_view.el)
    button.hide()
    @$el.append button
    button.fadeIn()



###

Begin Button View
-----------------

The Begin button kicks off the beginning of the game.

###
class BeginButtonView extends View
  tagName: "button"
  className: "btn btn-lg btn-success btn-begin"

  initialize: (options) ->
    super options
    @dispatcher.on 'hide:begin-button', =>

  events:
    "click": "on_begin"

  render: ->
    text = this.options.begin_text || '<em>Begin!</em>'
    this.$el.html text

  on_begin: =>
    @dispatcher.trigger 'begin'
    @dispatcher.trigger 'hide:begin-button', @$el
    if !@$el.is(':animated')
      @$el.hide()


###

The Situations View
-------------------

The Situations View handles adding new Situations to the current state.

###
class SituationsView extends View
  initialize: (options) ->
    super options
    this.situations = {}
    this.collection.on 'add', this.on_add_situation

  on_add_situation: (model) =>
    console.log "Adding new situation view:", model, @el, this
    situation = new SituationView
      model: model

    @situations[model.cid] = situation
    situation.render()
    situation.$el.hide()
    @$el.append situation.el
    @dispatcher.trigger "show:situation", situation.$el
    if !situation.$el.is(':animated')
      situation.$el.show()

###

Situation View
--------------

A Situation View handles a single Situation display.

###
class SituationView extends View
  tagName: "section"
  className: "situation center-block"

  render: ->
    content = this.model.get 'content'

    this.$el.html markdown.render content


###

The Root View
-------------

###

class RootView extends Backbone.View
  initialize: (options) ->
    super options
    @views =
      title: new TitleView options.get_options
        el: @$('.banner').get(0)

      situations: new SituationsView options.get_options
        collection: options.stack
        el: @$('.situations').get(0)

    @views.title.render()


###

The Dreamhorn Object
--------------------

The Dreamhorn object is entrypoint into the application.

###
class Dreamhorn
  constructor: (options) ->
    @options = options || {}
    @dispatcher = _.extend {}, Backbone.Events
    @root = null

    @situations = new Situations [], @get_options()
    @stack = new Situations [], @get_options()
    @world = new World {}, @get_options()
    @items = new Items [], @get_options()

    @dispatcher.on "all", () =>
      console.log "Action dispatched:", arguments

    @stack.on "all", () =>
      console.log "Stack:", arguments

    @dispatcher.on "begin", () =>
      console.log "Beginning!"
      begin_id = @options.begin_situation || 'begin'
      begin = @situations.get begin_id
      @stack.push begin

  get_options: (suboptions) ->
    options =
      situations: @situations
      stack: @stack
      world: @world
      items: @items
      dispatcher: @dispatcher
      $root: @$el
      get_options: (suboptions) ->
        _.extend(
          {},
          _.omit(
            this,
            [
              'model', 'collection',
              'el', '$el', 'id',
              'className', 'tagName',
              'attributes', 'events',
            ]
          ),
          suboptions,
        )

    return _.extend {}, @options, options, suboptions

  situation: (id, data) ->
    data.id = id
    @situations.add(data)

  init: (el) ->
    options = @get_options
      el: el
    @root = new RootView options



module.exports = new Dreamhorn()
