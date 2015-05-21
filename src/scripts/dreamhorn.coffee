# The Dreamhorn Library
# =====================
#
# *In which we get down to brass tacks.*
#
# Dreamhorn is a platform for choice-based interactive fiction, inspired by Undum
# and Raconteur. You can read more about it in the [Introduction][intro].
#
# Preamble
# --------
#
# Here we go then. You've already met [jQuery][jquery]:
#
$ = require('jquery')

# Next, we'll be needing [lodash][lodash], a utility library that's useful to
# have on hand. It's also required by Backbone, which is coming up next.
#
_ = require('lodash')

# Ah, [Backbone][backbone]. You'll be seeing a lot of it. As the name suggests,
# Backbone will be providing the spine of the application to follow.
#
Backbone = require('backbone')

# Our config library makes its reprise. We'll be needing it shortly.
#
config = require('./config')

# And, of course, we'll be needing something to translate [Markdown][markdown]
# into HTML. The [`markdown-it`][markdown-it] package will do very
# nicely. We'll provide it with configuration from our `config` object.
#
markdown = require('markdown-it') 'default', config.markdown


# Models & Collections
# --------------------
#
# We'll use [`Backbone.Model`][models] for storing all story state. We'll use
# [`Backbone.Collection`][collections] for storing collections of models.
#
# Here, we make a custom `Model` to handle a custom `dispatcher` object that
# we'll be passing around.
#
class Model extends Backbone.Model
  # [Coffeescript classes][coffee-class] can define constructor
  # methods that set up the instance. `constructor` is called before Backbone's
  # [`initialize`][backbone-initialize].
  #
  constructor: (data, options) ->
    @dispatcher = options.dispatcher if options
    super data, options

# And again, we make a custom `Collection` to handle that custom `dispatcher`
# object that we'll be passing around.
#
class Collection extends Backbone.Collection
  constructor: (models, options) ->
    @dispatcher = options.dispatcher if options
    super models, options



# World
# -----
#
# `World` is a [model][models] that contains the state of the game world.
class World extends Model


# Items
# -----
#
# `Items` is a [collection][collections] that will contain the player
# inventory.
#
class Items extends Collection

# Situation
# ---------
#
# A Situation is a custom [model][models] that corresponds to a presentation of
# text and choices. We'll explore this more deeply in our usage example, [The
# Cloak of Darkness][main].
#
class Situation extends Model
  # Here we meet Backbone's [`initialize`][backbone-initialize] in the
  # wild. Again, this gets called *after* the Model constructor defined above.
  initialize: (attributes, options) ->
    super attributes, options
    @template = _.template @get 'content'


# Situations
# ----------
#
# We'll use `Situations` [collection][collections] for several purposes: one, a global registry
# of available situations; two, a stack of currently-active situations.
#
class Situations extends Collection
  # By defining `model` here, [`Collection.add()`][collection-add] will
  # rehydrate a plain old Javascript object into a fancy-pants [Backbone
  # Model][models].
  #
  model: Situation


# Quality
# -------
#
# FIXME: Still need to figure out how these will work!
#
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



# Views
# -----

# [`Backbone.View`][views] provides a way to render data to the page, and a way
# to handle events generated on the page. Again, here we're just creating a
# custom view that knows about our dispatcher.
#
class View extends Backbone.View
  initialize: (options) ->
    @options = options
    @dispatcher = options.dispatcher
    super options



# The Title View
# --------------
#
# Our first real do-something [view][views]. The Title View presents the title
# of the piece, and provides the entrypoint into the first Situation, via the
# Back Button View..
#
class TitleView extends View
  # Backbone views automatically create an empty DOM element that we can insert
  # into the page document later. Here, we control the properties of that
  # element.
  tagName: "header"
  className: "title"

  # Views have [`initialize`][backbone-initialize] methods as well. As usual,
  # they will be called after the constructor.
  initialize: (options) ->
    super options
    @set_button_view()
    @render()
    # Here we begin to see our dispatcher at work. The dispatcher is a simple
    # [backbone.Events][backbone-events] object that we will use to coordinate
    # actions across the application, allowing our application components to be
    # [loosely coupled][loose-coupling].
    #
    @dispatcher.on 'reset', @on_reset
    @dispatcher.on 'begin', @on_begin

  # Views can define a `render` method that should take care of the business of
  # rendering this view's element, including adding any sub-views' elements to
  # this view's element.
  #
  # Here we render our button sub-view and add its element to our own.
  render: ->
    @button_view.render()
    button = $ '<p></p>'
    button.append(@button_view.el)
    button.hide()
    @$el.append button
    @dispatcher.trigger "show:begin-button", button

  # When the story begins, we may wish to reduce the size of the title
  # "jumbotron", which is rather imposing, especially if we're not intending to
  # scroll far down the page. To see how this might be handled, visit the
  # [Effects][effects] appendix.
  #
  begin: ->
    @dispatcher.trigger "reduce:title", @$el

  set_button_view: ->
    @button_view = new BeginButtonView @options.get_options()

  # When we reset the view (or set it up for the first time!) we'll need to
  # instantiate a button view and restore the title "jumbotron" to its original size and state.
  reset: ->
    @dispatcher.trigger "expand:title", @$el
    @set_button_view()
    @render()

  # Signal handlers attached to the `@dispatcher` above. We could use `begin`
  # and `reset` directly as the signal handlers, but I prefer to separate the
  # handler from the actual implementation, for naming purposes. Also, note the
  # `=>`, which is [Coffeescript's way][fat-arrow] of ensuring that these methods remain
  # bound to their object.
  #
  on_begin: =>
    @begin()

  on_reset: =>
    @reset()


# Begin Button View
# -----------------
#
# The Begin button kicks off the beginning of the game when you click it.
#
class BeginButtonView extends View
  tagName: "button"
  className: "btn btn-lg btn-success btn-begin"

  initialize: (options) ->
    super options

  # Views that handle DOM events can [define their event
  # handlers][view-dom-event-handlers] by name here:
  #
  events:
    "click": "on_click"

  render: ->
    text = this.options.begin_text || '<em>Begin!</em>'
    this.$el.html text

  # The handler for the DOM `click` event. Here we send, or `trigger` events on
  # the dispatcher, rather than listening for them.
  on_click: =>
    # `begin` signifies that the story has started.
    @dispatcher.trigger 'begin', @$el
    # Once the button is clicked, we want to remove the button from play. A
    # handler for this event should finish by removing the button from the DOM.
    # To see how this might be handled, visit the [Effects][effects] appendix.
    @dispatcher.trigger 'remove:begin-button', @$el



# The Situations View
# -------------------

# The Situations View handles adding new Situations to the current state. It takes over the
#
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

  rerender_latest: ->
    model = @collection.last()
    situation = @get_situation_from_model model
    situation.render()

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
    trigger = @dispatcher.blackboard.get('last-trigger')
    @dispatcher.trigger "show:situation", situation.$el, trigger, duration
    _.delay((() -> situation.$el.show()), duration)

  remove_situation: (situation) ->
    trigger = @dispatcher.blackboard.get('last-trigger')
    @dispatcher.trigger "remove:situation", situation.$el, trigger

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



# Situation View
# --------------

# A Situation View handles a single Situation display.

class SituationView extends View
  tagName: "section"
  className: "situation center-block card card-hoverable"

  events:
    "click a": "on_click"

  render_template: (template) ->
    context = _.extend {}, @options.get_options(), @model.toJSON()
    result = template context
    html = markdown.render result
    return $ html

  render: ->
    @body = $ '<div class="card-body">'
    @footer = $ '<div class="card-footer">'
    rendered = @render_template @model.template

    rendered.find('a').not('.raw').each (idx, el) ->
      $el = $ el
      href = $el.attr('href')
      $el.data 'href', href
      $el.attr('href', undefined)
    @body.html(rendered)
    @$el.html ''
    @$el.append @body
    @$el.append @footer

    classes = @model.get('classes')
    if classes
      @$el.addClass(classes)

    @$el.attr('data-situation', @model.get('id'))


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
      @body.append rendered

  on_click: (evt) =>
    $a = $ evt.target
    @dispatcher.blackboard.set('last-trigger', $a)

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

# The Root View
# -------------


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



# The Dreamhorn Object
# --------------------

# The Dreamhorn object is entrypoint into the application.

class Dreamhorn
  constructor: (options) ->
    @options = options || {}
    @dispatcher = _.extend {}, Backbone.Events
    @dispatcher.blackboard = new Backbone.Model()
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

  Model: Model,
  Collection: Collection,
  World: World,
  Items: Items,
  Situation: Situation,
  Situations: Situations,
  View: View,
  TitleView: TitleView,
  BeginButtonView: BeginButtonView,
  SituationsView: SituationsView,
  SituationView: SituationView,
  RootView: RootView,

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

# [backbone]: <http://backbonejs.org/>
# [backbone-events]: http://backbonejs.org/#Events
# [coffee]: <http://coffeescript.org/>
# [coffee-class]: <http://coffeescript.org/#classes>
# [coffee-initialize]: <http://backbonejs.org/#Model-constructor>
# [collections]: <http://backbonejs.org/#Collection>
# [collection-add]: http://backbonejs.org/#Collection-add
# [effects]: ./effects.html
# [fat-arrow]: http://coffeescript.org/#fat-arrow
# [intro]: ./index.html
# [main]: ./main.html
# [jquery]: <http://jquery.com/>
# [lodash]: <https://lodash.com>
# [loose-coupling]: https://en.wikipedia.org/wiki/Loose_coupling
# [markdown]: <http://daringfireball.net/projects/markdown/syntax>
# [markdown-it]: <https://markdown-it.github.io/>
# [models]: <http://backbonejs.org/#Model>
# [view-dom-event-handlers]: http://backbonejs.org/#View-delegateEvents
# [views]: http://backbonejs.org/#View
