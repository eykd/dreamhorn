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

# The [Chance.js][chance] library provides myriad useful randomization tools.
#
Chance = require('chance')

# Our config library makes its reprise. We'll be needing it shortly.
#
config = require('./game/config')

# And, of course, we'll be needing something to translate [Markdown][markdown]
# into HTML. The [`marked`][marked] package will do very
# nicely. We'll provide it with configuration from our `config` object.
#
markdown = require('marked')
markdown.setOptions config.markdown

# Finally, we need to be able to hash the contents of a string. MD5 will work
# nicely:
#
md5 = require('MD5')


# Configuration
# -------------
#
# We'll want to make sure that our configuration is populated with proper defaults.
#
defaults =
  # The name of the situation to begin with:
  begin_situation: 'begin'

  # And the text to show in the button at the beginning:
  begin_text: "<em>Begin!</em>"

  # The default action to take when none is specified:
  default_action: 'push'

  # Options for [controlling Markdown rendering behavior][marked-options]:
  markdown:
    gfm: false
    tables: true
    breaks: false
    pedantic: false
    sanitize: false
    smartLists: true
    smartypants: true

  template:
    escape: /<<-([\s\S]+?)>>/g
    evaluate: /<%([\s\S]+?)%>/g
    interpolate: /<<([\s\S]+?)>>/g
    variable: ""

  # Options controlling animation effect behavior:
  effects:
    base_animation_duration: 500

  # The base seed for deterministic randomness
  seed: Math.random()

config = _.extend {}, defaults, config

# Here we'll take a moment to configure our templates:
#
_.extend _.templateSettings, config.template


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


# Item
# ----
#
# An `Item` is a thing that you do things to or with.
class Item extends Model


# Items
# -----
#
# `Items` is a [collection][collections] that holds items.
#
class Items extends Collection
  model: Item


# Character
# ---------
#
# A `Character` is a person within a narrative. We'll set up a bunch of useful
# pronouns, based on whether the `sex` attribute of the character.
class Character extends Model
  initialize: (attrs) ->
    sex = if attrs.sex then attrs.sex.toLowerCase() else ''
    pronouns =
      # Subject pronoun:
      sp: pronoun sex, 'he', 'she', 'they'
      SP: pronoun sex, 'He', 'She', 'They'
      # Object pronoun:
      op: pronoun sex, 'him', 'her', 'them'
      OP: pronoun sex, 'Him', 'Her', 'Them'
      # Reflexive pronoun:
      rp: pronoun sex, 'himself', 'herself', 'themself'
      RP: pronoun sex, 'Himself', 'Herself', 'Themself'
      # Possessive adjective:
      pa: pronoun sex, 'his', 'her', 'their'
      PA: pronoun sex, 'His', 'Her', 'Their'
      # Possessive pronoun
      pp: pronoun sex, 'his', 'hers', 'theirs'
      PP: pronoun sex, 'His', 'Hers', 'Theirs'

    # In the interest of making pronouns in templates very easy to work with,
    # we'll add lots of convenient shortcuts:
    pronouns.he = pronouns.sp
    pronouns.He = pronouns.SP
    pronouns.him = pronouns.op
    pronouns.Him = pronouns.OP
    pronouns.himself = pronouns.rp
    pronouns.Himself = pronouns.RP
    # But some pronouns overlap, which isn't very convenient:
    pronouns.his_poss_adj = pronouns.pa
    pronouns.His_poss_adj = pronouns.PA
    pronouns.his_poss_pro = pronouns.pp
    pronouns.His_poss_pro = pronouns.PP

    pronouns.she = pronouns.sp
    pronouns.She = pronouns.SP
    pronouns.her_obj = pronouns.op
    pronouns.Her_obj = pronouns.OP
    pronouns.herself = pronouns.rp
    pronouns.Herself = pronouns.RP
    pronouns.her_poss_adj = pronouns.pa
    pronouns.Her_poss_adj = pronouns.PA
    pronouns.hers = pronouns.pp
    pronouns.Hers = pronouns.PP

    pronouns.they = pronouns.sp
    pronouns.They = pronouns.SP
    pronouns.them = pronouns.op
    pronouns.Them = pronouns.OP
    pronouns.themself = pronouns.rp
    pronouns.Themself = pronouns.RP
    pronouns.their = pronouns.pa
    pronouns.Their = pronouns.PA
    pronouns.theirs = pronouns.pp
    pronouns.Theirs = pronouns.PP

    if attrs.first
      # Possessive first name
      pronouns.pfirst = attrs.first + "'s"
    if attrs.last
      # Possessive last name
      pronouns.plast = attrs.last + "'s"
    if attrs.name
      # Possessive name
      pronouns.pname = attrs.name + "'s"

    @set pronouns

# Characters
# -----
#
# `Characters` is a [collection][collections] that will contain characters.
#
class Characters extends Collection
  model: Character


# Helper functions
# ----------------
#
# Choose a pronoun based on whether the character's `sex` attribute is
# 'male', 'female', or otherwise..
pronoun = (sex, male_pronoun, female_pronoun, otherwise) ->
  # If the `sex` object has a `sex` attribute (e.g. a Character's `attributes`
  # object), we'll use that instead.
  if sex.sex
    sex = sex.sex
  sex = sex.toLowerCase()
  if sex == 'male'
    return male_pronoun
  else if sex == 'female'
    return female_pronoun
  else
    return otherwise


one_of_cache = {}

# one_of
# ------
#
# Work easily with a sequence of strings.
one_of = () ->
  sequence = Array.prototype.slice.call(arguments)

  # If we've seen this sequence before, we want to use a cached version of our
  # iterators to maintain state in between uses.
  hash = md5(JSON.stringify(sequence))
  obj = one_of_cache[hash]

  if not obj
    # Here we build the `one_of` object with its iterator functions. Each
    # stores its state inside a closure.
    obj = one_of_cache[hash] =
      # Cycle through the sequence, returning each item in order and wrapping
      # back to the beginning.
      cycling: (() ->
        cycler = sequence.slice()
        i = -1
        return () ->
          i += 1
          if i >= cycler.length
            i = 0
          return cycler[i]
        )()

      # Cycle through the sequence, returning each item in order until we reach
      # the end of the sequence. Continue to return the last item forevermore
      # after.
      stopping: (() ->
        cycler = sequence.slice()
        i = -1
        return () ->
          i += 1
          if i >= cycler.length
            i = cycler.length - 1
          return cycler[i]
        )()

      # Return a random item from the sequence. Crucially, it won't return the
      # same item twice in a row.
      randomly: (() ->
        last_item = null
        return () ->
          item = last_item
          while item == last_item
            item = D.chance.pick sequence
          last_item = item
          return item
        )()

      # Return a random item from the sequence. May return the same item twice
      # or more times in a row!
      truly_at_random: (() ->
        return () ->
          return D.chance.pick sequence
        )()

      # Shuffle the sequence and iterate through, wrapping around to the
      # beginning of the shuffled sequence.
      in_random_order: (() ->
        cycler = D.chance.shuffle sequence
        i = -1
        return () ->
          i += 1
          if i >= cycler.length
            i = cycler.length - 1
          return cycler[i]
        )()

  return obj


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
    @template = as_template @get 'content'


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


# Template Rendering
# ------------------
#
# We use [lodash templates][templates], which provides a powerful and
# expressive template language (essentially, it's just interpolated
# javascript).
#
as_template = (content) ->
  if _.isFunction content
    content = content()

  imports =
    pronoun: pronoun
    D: D
    _: _

  D.dispatcher.trigger 'set-template-imports', imports
  return _.template content,
    imports: imports


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
    text = config.begin_text
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

  deactivate_all: ->
    @collection.forEach (model) =>
      situation = @get_situation_from_model model
      @deactivate_situation(situation)

  deactivate_situation: (situation) ->
    @dispatcher.trigger 'deactivate:situation', situation

  activate_situation: (situation) ->
    @dispatcher.trigger 'activate:situation', situation

  reactivate_latest: ->
    model = @collection.last()
    situation = @get_situation_from_model model
    @activate_situation(situation)

  show_situation: (situation) ->
    duration = @options.show_animation_duration || 500
    trigger = @dispatcher.blackboard.get('last-trigger')
    @dispatcher.trigger "show:situation", situation.$el, trigger
    _.delay((() -> situation.$el.show()), duration)

  remove_situation: (situation) ->
    trigger = @dispatcher.blackboard.get('last-trigger')
    @dispatcher.trigger "remove:situation", situation.$el, trigger

  push: (model, data) =>
    @deactivate_all()
    situation = @get_situation_from_model model
    @run_before_entering situation
    if data
      prepend = data.prepend
      if prepend and data.prepend_newline
        prepend += '\n\n'
    situation.render(prepend)
    situation.$el.hide()
    @$el.append situation.el
    @show_situation situation
    @run_after_entering situation

  pop: (model, data) =>
    if not _.isUndefined data
      reactivate = if _.isUndefined(data.reactivate) then true else false
    else
      reactivate = true
    situation = @get_situation_from_model model
    @run_before_exiting situation
    @remove_situation situation
    @run_after_exiting situation
    delete @situations[model.cid]
    if reactivate
      @reactivate_latest()

  on_push: (model, data) =>
    @push model, data

  on_replace: (popped, pushed, data) =>
    data.reactivate = false
    @pop popped, data
    @push pushed, data

  on_pop: (model, data) =>
    @pop model, data

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
    "input *": "on_input"
    "change *": "on_input"

  get_context: (extra_context) ->
    context = _.extend(
      {},
      @options.get_options(),
      @model.toJSON(),
      {world: @options.world.attributes},
      extra_context)
    @dispatcher.trigger 'set-template-context', context
    return context

  render_template: (template, prepend) ->
    context = @get_context()
    result = template context
    if not _.isUndefined(prepend)
      result = "#{prepend}#{result}"
    html = markdown result
    return $ html

  render: (prepend) ->
    @body = $ '<div class="card-body">'
    rendered = @render_template @model.template, prepend

    rendered.find('a').not('.raw').each (idx, el) ->
      $el = $ el
      href = $el.attr('href')
      $el.data 'href', href
      $el.attr('href', 'javascript:void(0)')
    @body.html(rendered)
    @$el.html ''
    @$el.append @body

    choices = @model.get('choices')
    if choices
      if _.isFunction choices
        choices = choices()
      $footer = $ '<footer class="card-footer">'
      @$el.append $footer
      $choices = $ '<ul class="choices">'

      for text, directive of choices
        text = as_template(text) @get_context()
        text = _.trimRight(text)
        if not _.isString directive
          id = directive.get('id')
          action = config.default_action
          directive = "#{action}!#{id}"
        if _.endsWith text, '//'
          prepend_newline = _.endsWith text, '///'
          text = _.trimRight text, '/'
          optional_p = /\[([^\]+])\](.+)$/
          anchor_text = text.replace optional_p, '$2'
          prepend_text = text.replace optional_p, '$1'
        else
          anchor_text = text
          prepend_text = ''
          prepend_newline = false
        html = markdown anchor_text
        $choice = $ """
          <li>
            <a href="javascript:void(0)"
               data-href="#{directive}">
            #{html}
            </a>
          </li>"""
        $a = $choice.find('a').first()
        # Rather than set the `data-` attributes in the template, we'll use Zepto
        # to set data on the DOM element directly, so we don't have to worry
        # about serialization concerns.
        $a.data('prepend', prepend_text)
        $a.data('prepend-newline', prepend_newline)
        $choices.append $choice

      $footer.append($choices)

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
    @write action($el)

  write: (text) ->
    @body.append @render_template as_template text

  on_click: (evt) =>
    console.log "a Click!", evt.target
    $a = $(evt.target).closest('a')
    @dispatcher.blackboard.set('last-trigger', $a)

    if not $a.hasClass 'raw'
      evt.preventDefault()
      if not $a.hasClass 'disabled'
        [event, data] = @parse_directive $a.text(), $a.data('href')
        data.prepend = $a.data('prepend') or data.prepend
        data.prepend_newline = $a.data('prepend-newline') or data.prepend_newline
        data.click = evt
        data.anchor = $a
        if @is_action event
          @handle_action event, $a
          @dispatcher.trigger 'action', event, data
        else
          @dispatcher.trigger event, data

  on_input: _.debounce(((evt) =>
      $input = $ evt.target
      name = $input.attr 'name'
      value = $input.val()
      D.world.set(name, value)
      console.log $input.attr('name'), $input.val()
    ), 300)
  parse_directive: (text, directive) ->
    data = {event: event, text: text, directive: directive}
    if directive == '!'
      if @is_action text
        # !: Trigger an event of the same name as anchor text
        data.event = text
      else
        data.event = config.default_action
        data.target = text
    else if '!' in directive
      if _.startsWith directive, '!'
        # !event: Trigger the event named
        data.event = _.trimLeft directive, '!'
      else
        # action!arg: Call the action with the given argument
        [data.event, data.target] = directive.split '!', 2
    else
      data.event = config.default_action
      data.target = directive

    if not data.target
      data.target = text.toLowerCase()

    event = data.event.toLowerCase()

    console.log "Parsed directive", text, directive, 'as', event, data
    return [event, data]

# The Root View
# -------------


class RootView extends View
  initialize: (options) ->
    super options
    @dispatcher.on "reset", @reset

    @views =
      title: new TitleView options.get_options
        el: @$('#header').get(0)

      situations: new SituationsView options.get_options
        collection: options.stack
        el: @$('#situations').get(0)

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
    @seen = {}

    seed = config.seed
    @world.set 'seed', seed
    @chance = new Chance seed
    @roll = () =>
      return @chance.rpg.apply @chance, arguments

    @dispatcher.on "all", () =>
      console.log "Action dispatched:", arguments

    @dispatcher.on "begin", () =>
      begin_id = @options.begin_situation || 'begin'
      @push {target: begin_id}

    @dispatcher.on "replace", @replace

    @dispatcher.on "push", @push

    @dispatcher.on "pop", @pop

  config: config
  next: '-->'

  Model: Model
  Collection: Collection
  World: World
  Item: Item
  Items: Items
  Character: Character
  Characters: Characters
  Situation: Situation
  Situations: Situations
  View: View
  TitleView: TitleView
  BeginButtonView: BeginButtonView
  SituationsView: SituationsView
  SituationView: SituationView
  RootView: RootView

  push: (data) =>
    if _.isString data
      situation_id = data
      data = {target: situation_id}
    else
      situation_id = data.target
    if situation_id == '-->'
      # Get the next situation in sequence
      current = @stack.last()
      index = @situations.indexOf(current)
      situation = @situations.at(index + 1)
      situation_id = situation.get('id')
    else
      situation = @situations.get situation_id
    if not situation
      throw new Error "No such situation #{situation_id}"
    seen = @seen[situation_id]
    @seen[situation_id] = if not seen then 1 else seen + 1
    @stack.push situation
    @stack.trigger 'push', situation, data
    return situation

  pop: (data) =>
    situation = @stack.pop()
    @stack.trigger 'pop', situation, data
    return situation

  replace: (data) =>
    if _.isString(data)
      situation_id = data
      data = {target: situation_id}
    else
      situation_id = data.target
    popped = @stack.pop()
    situation = @situations.get situation_id
    @stack.push situation
    @stack.trigger 'replace', popped, situation, data
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
      id = data.id = md5(JSON.stringify(data))
      console.log "Constructed MD5 ID #{id} for", data
    @situations.add(data)
    return @situations.get id

  init: (options) ->
    @options = _.extend {}, @options, options
    @root = new RootView @get_options()
    @dispatcher.trigger 'init', this


D = module.exports = new Dreamhorn()

# [backbone]: <http://backbonejs.org/>
# [backbone-events]: http://backbonejs.org/#Events
# [chance]: http://chancejs.com/
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
# [marked-options]: https://github.com/chjj/marked#usage
# [models]: <http://backbonejs.org/#Model>
# [templates]: https://lodash.com/docs#template
# [view-dom-event-handlers]: http://backbonejs.org/#View-delegateEvents
# [views]: http://backbonejs.org/#View
