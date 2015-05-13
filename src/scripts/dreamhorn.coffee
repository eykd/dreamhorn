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
  initialize: (attributes, options) ->
    super attributes, options
    @template = _.template @get 'content'


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
    this.collection.on 'remove', this.on_remove_situation

  on_add_situation: (model) =>
    situation = new SituationView @options.get_options
      model: model

    before = model.get('before')
    if _.isFunction before
      before situation.options
    @situations[model.cid] = situation
    situation.render()
    situation.$el.hide()
    @$el.append situation.el
    @dispatcher.trigger "show:situation", situation.$el
    if not situation.$el.is(':animated')
      situation.$el.show()
    after = model.get('after')
    if _.isFunction after
      after situation.options

  on_remove_situation: (model) =>
    situation = @situations[model.cid]
    situation.unlink()
    @dispatcher.trigger "hide:situation", situation.$el

###

Situation View
--------------

A Situation View handles a single Situation display.

###
class SituationView extends View
  tagName: "section"
  className: "situation center-block"

  events:
    "click a": "on_click"

  render: ->
    context = _.extend {}, @options.get_options(), @model.toJSON()
    content = this.model.template context

    this.$el.html markdown.render content

  unlink: ->
    this.$('a').not('.sticky').contents().unwrap()

  on_click: (evt) =>
    $a = $ evt.target

    if not $a.hasClass 'raw'
      evt.preventDefault()
      [event, arg] = @parse_directive $a.text(), $a.attr('href')
      @dispatcher.trigger event, arg

  parse_directive: (text, directive) ->
    event = null
    arg = undefined
    if directive == '!'
      # !: Trigger an event of the same name as anchor text
      event = text
    else if '!' in directive
      if _.startsWith directive, '!'
        # !event: Trigger the event named
        event = _.trimLeft directive, '!'
      else
        # action!arg: Call the action with the given argument
        [event, arg] = directive.split '!', 2
    else
      event = directive

    return [event, arg]
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

    @dispatcher.on "begin", () =>
      begin_id = @options.begin_situation || 'begin'
      begin = @situations.get begin_id
      @stack.push begin

    @dispatcher.on "replace", (situation_id) =>
      @stack.pop()
      @stack.push @situations.get situation_id

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
