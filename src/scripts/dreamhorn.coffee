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
    @reset()
    @dispatcher.on 'reset', @reset
    @dispatcher.on 'begin', @begin

  render: ->
    @button_view.render()
    button = $ '<p></p>'
    button.append(@button_view.el)
    button.hide()
    @$el.append button
    button.fadeIn()

  begin: =>
    @$el.removeClass('jumbotron').addClass('page-header')

  reset: =>
    @$el.removeClass('page-header').addClass('jumbotron')
    @button_view = new BeginButtonView @options.get_options()
    @render()

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

  events:
    "click": "on_begin"

  render: ->
    text = this.options.begin_text || '<em>Begin!</em>'
    this.$el.html text

  on_begin: =>
    @dispatcher.trigger 'begin'
    duration = @options.hide_animation_duration || 500
    @dispatcher.trigger 'remove:begin-button', @$el, duration
    _.delay((() => @$el.remove()), duration)


###

The Situations View
-------------------

The Situations View handles adding new Situations to the current state.

###
class SituationsView extends View
  initialize: (options) ->
    super options
    @situations = {}
    @collection.on 'push', this.on_push
    @collection.on 'pop', this.on_pop
    @collection.on 'replace', this.on_replace
    @dispatcher.on 'reset', this.on_reset

  unlink_all_but_last: ->
    _.forEach @collection.slice(0, @situations.length), (model) =>
      situation = @get_situation_from_model model
      situation.unlink()

  unlink_all: ->
    @collection.forEach (model) =>
      situation = @get_situation_from_model model
      situation.unlink()

  relink_latest: ->
    model = @collection.last()
    situation = @get_situation_from_model model
    situation.relink()

  get_situation_from_model: (model) ->
    if not @situations[model.cid]
      situation = new SituationView @options.get_options
        model: model
      @situations[model.cid] = situation

    return @situations[model.cid]

  run_before_entering: (situation) ->
    model = situation.model
    before = model.get('before_enter')
    if _.isFunction before
      before situation.options

  run_after_entering: (situation) ->
    model = situation.model
    after = model.get('after_enter')
    if _.isFunction after
      after situation.options

  run_before_exiting: (situation) ->
    model = situation.model
    before = model.get('before_exit')
    if _.isFunction before
      before situation.options

  run_after_exiting: (situation) ->
    model = situation.model
    after = model.get('after_exit')
    if _.isFunction after
      after situation.options

  show_situation: (situation) ->
    duration = @options.show_animation_duration || 500
    @dispatcher.trigger "show:situation", situation.$el, duration
    _.delay((() -> situation.$el.show()), duration)

  remove_situation: (situation) ->
    duration = @options.hide_animation_duration || 500
    @dispatcher.trigger "remove:situation", situation.$el, duration
    _.delay((() -> situation.$el.remove()), duration)

  push: (model) =>
    @unlink_all()
    situation = @get_situation_from_model model
    @run_before_entering situation
    situation.render()
    situation.$el.hide()
    @$el.append situation.el
    @show_situation situation
    @run_after_entering situation

  pop: (model, relink=true) =>
    situation = @get_situation_from_model model
    @run_before_exiting situation
    @remove_situation situation
    @run_after_exiting situation
    delete @situations[model.cid]
    if relink
      @relink_latest()

  on_push: (model) =>
    @push model

  on_replace: (popped, pushed) =>
    @pop popped, relink=false
    @push pushed

  on_pop: (model) =>
    @pop model

  on_reset: () =>
    for cid, situation of @situations
      situation.remove()
    @situations = {}


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

  render_template: (template) ->
    context = _.extend {}, @options.get_options(), @model.toJSON()
    result = template context
    html = markdown.render result
    return $ html

  render: ->
    rendered = @render_template @model.template

    rendered.find('a').not('.raw').each (idx, el) ->
      $el = $ el
      href = $el.attr('href')
      $el.data 'href', href
      $el.attr('href', undefined)

    @$el.html rendered

  unlink: ->
    @$('a').not('.sticky').addClass('disabled')

  relink: ->
    @$('a.disabled').removeClass('disabled')

  is_action: (event) ->
    actions = @model.get('actions')
    if actions
      return event of actions
    else
      return false

  handle_action: (event, $el) ->
    actions = @model.get('actions')
    action = actions[event]
    result = action($el)
    if _.isString result
      template = _.template result
      rendered = @render_template template
      @$el.append rendered

  on_click: (evt) =>
    $a = $ evt.target

    if not $a.hasClass 'raw'
      evt.preventDefault()
      if not $a.hasClass 'disabled'
        [event, arg] = @parse_directive $a.text(), $a.data('href')
        if @is_action event
          @handle_action event, $a
          @dispatcher.trigger 'action', event, arg
        else
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

    if not arg
      arg = text.toLowerCase()

    event = event.toLowerCase()

    console.log "Parsed directive", text, directive, 'as', event, arg
    return [event, arg]
###

The Root View
-------------

###

class RootView extends View
  initialize: (options) ->
    super options
    @dispatcher.on "reset", @reset

    @views =
      title: new TitleView options.get_options
        el: @$('.banner').get(0)

      situations: new SituationsView options.get_options
        collection: options.stack
        el: @$('.situations').get(0)

    @views.title.render()

  reset: =>
    @$el.velocity 'scroll', {duration: 500}
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
      @push begin_id

    @dispatcher.on "replace", @replace

    @dispatcher.on "push", @push

    @dispatcher.on "pop", @pop

  push: (situation_id) =>
    situation = @situations.get situation_id
    if not situation
      throw new Error "No such situation #{situation_id}"
    @stack.push situation
    @stack.trigger 'push', situation
    return situation

  pop: (situation_id) =>
    situation = @stack.pop()
    @stack.trigger 'pop', situation
    return situation

  replace: (situation_id) =>
    popped = @stack.pop()
    situation = @situations.get situation_id
    @stack.push situation
    @stack.trigger 'replace', popped, situation
    return [popped, situation]

  get_options: (suboptions) ->
    options =
      situations: @situations
      stack: @stack
      world: @world
      items: @items
      dispatcher: @dispatcher
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

  reset: =>
    @stack.reset []
    @world.reset []
    @items.reset []

  situation: (id, data) ->
    if not data
      data = id
      id = data.id
    else
      data.id = id.toLowerCase()
    if not id
      throw new Error("No ID provided with new situation!")
    @situations.add(data)
    return @situations.get id

  init: (options) ->
    @options = _.extend {}, @options, options
    @root = new RootView @get_options()


module.exports = new Dreamhorn()
