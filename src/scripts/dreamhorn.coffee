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

# Our homegrown Ring library provides basic, extensible randomization tools.
Ring = require('./ring/core')
# We'll be registering one_of as a Handlebars template helper later.
require('./ring/one_of')

# Our config library makes its reprise. We'll be needing it shortly.
#
config = require('./game/config')

# We'll need the Handlebars templating library...
Handlebars = require('handlebars')

# And, of course, we'll be needing something to translate [Markdown][markdown]
# into HTML. The [`marked`][marked] package will do very
# nicely. We'll provide it with configuration from our `config` object.
#
marked = require('marked')

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
    # Enable github-flavored Markdown?
    gfm: true
    # Enable github-flavored Markdown tables? (requires `gfm` to be true)
    tables: true
    # Enable github-flavored Markdown line-breaks? (requires `gfm` to be true)
    breaks: false
    # Conform to obscure parts of markdown.pl as much as possible. Don't fix
    # any of the original markdown bugs or poor behavior.
    pedantic: false
    # Sanitize the output. Ignore any HTML that has been input.
    sanitize: false
    # Use smarter list behavior than the original markdown. May eventually be
    # default with the old behavior moved into pedantic.
    smartLists: true
    # Use "smart" typograhic punctuation for things like quotes and dashes.
    smartypants: true

  # Options controlling [lodash templating][_templates]:
  _template_settings:
    # A regular expression defining the HTML "escape" syntax, for safely
    # escaping a context variable containing HTML: `<<- foo >>`, where the
    # context is `{foo: "<script>evil()</script>"}`, produces
    # `&lt;script&gt;evil()&lt;/script&gt;`. This is equivalent to Handlebar's
    # `{{foo}}` syntax.
    escape: /<<-([\s\S]+?)>>/g
    # A regular expression defining the "evaluate" syntax, for raw javascript
    # interpolation: `<% if (foo) { %>bar<% } else { %>baz<% } %>`, where the
    # context is `{foo: true}`, produces `bar`. This is a more verbose and
    # javascripty version of Handlebar's block expressions. Use this when you get
    # annoyed with Handlebars.
    evaluate: /<%([\s\S]+?)%>/g
    # A regular expression defining the "interpolate" syntax, for interpolating
    # context variables *without* escaping them: `<< foo >>`, where the
    # context is `{foo: "<script>evil()</script>"}`, produces
    # `<script>evil()</script>`. This is equivalent to Handlebar's
    # `{{{foo}}}` syntax.
    interpolate: /<<([\s\S]+?)>>/g
    # If for some unfathomable reason you don't like that Handlebars uses a
    # `with` statement to make your context directly accessible within the
    # template, put a valid javascript name in here, and your context variables
    # will be namespaced inside that name. If you have no idea what that means,
    # feel free to ignore this, or read [all about it here][with-statement].
    variable: ""

  # Options controlling animation effect behavior:
  effects:
    base_animation_duration: 500

  # The base seed for deterministic randomness:
  seed: Math.floor Math.random() * 10000000000000000

  # Default templates
  # -----------------
  #
  # Default templates for basic UI. Be very careful if you override these!
  #
  # The outermost wrapper for a situation:
  situation_template: """

    <section class="situation center-block card card-hoverable"></section>

  """

  # The header of a situation (where the close button will be, if closeable):
  situation_header_template: """

    <div class="situation-header card-header">
      <div class="pull-right">
        <a data-href="drop!" href="javascript:void(0)" class="btn">Close</a>
    </div>

  """

  # The body of a situation (where the content of the situation will be displayed):
  situation_body_template: """

    <div class="situation-body card-body"></div>

  """

  # The footer of a situation (where the choices will be displayed):
  situation_footer_template: """

    <footer class="situation-footer card-footer"></footer>

  """

  # The outermost wrapper for the list of choices that will be displayed:
  situation_choices_template: """

    <ul class="choices"></ul>

  """

  # How each choice will be displayed:
  situation_choice_template: """
    <li>
      <a href="javascript:void(0)"
         data-href="{{{directive}}}">
      {{{html}}}
      </a>
    </li>"""

# Now, set up our configuration object with defaults overridden by the
# user-customized configuration.
config = _.extend {}, defaults, config

# Here we'll take a moment to configure our templates:
_.extend _.templateSettings, config._template_settings

# And markdown:
marked.setOptions config.markdown


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
# pronouns, based on the `sex` attribute of the character.
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

# We'll also make `pronoun` available as a helper inside of Handlebar
# templates:
Handlebars.registerHelper 'pronoun', pronoun



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
# We use [Handlebar templates][handlebars] *and* [lodash
# templates][_templates], which provide a powerful and expressive pair of
# template languages. Handlebar templates are simple and expressive. Lodash
# templates are essentially just interpolated javascript, and hence very
# powerful, but a bit harder to type for the common case. Use whichever feels
# most comfortable and expressive.
#
as_template = (content) ->
  # The content may itself be a function which must resolve to a
  # string.
  if _.isFunction content
    content = content()

  # For Lodash templates, we'll provide some useful default context.
  _imports =
    pronoun: pronoun
    _: _

  # We'll also offer the chance for custom handlers to extend the Lodash
  # context.
  D.dispatcher.trigger 'set-template-imports', _imports

  # Now, we compile the Handlebars template.
  template = Handlebars.compile content

  # And we return a wrapper function which will apply the lodash template to
  # the rendered Handlebars template, and render that. Sure, it's a bit
  # inefficient, but it works.
  return (context) ->
    result = template context
    _tmpl = _.template result,
      imports: _imports
    return _tmpl context


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
    @collection.on 'clear', this.on_reset
    @dispatcher.on 'reset', this.on_reset

  # This will unlink any active links in all visible situation views, except
  # for the one at the top of the stack.
  unlink_all_but_last: ->
    _.forEach @collection.slice(0, @situations.length), (model) =>
      situation = @get_situation_from_model model
      situation.unlink()

  # This will unlink any active links in all visible situation views.
  unlink_all: ->
    @collection.forEach (model) =>
      situation = @get_situation_from_model model
      situation.unlink()

  # This will relink deactivated links in the situation view at the top of the
  # stack.
  relink_latest: ->
    model = @collection.last()
    situation = @get_situation_from_model model
    situation.relink()

  # This will rerenderthe situation view at the top of the stack.
  rerender_latest: ->
    model = @collection.last()
    situation = @get_situation_from_model model
    situation.render()

  # Get the SituationView for the given Situation model. If one does not
  # already exist, create one.
  get_situation_from_model: (model) ->
    if not @situations[model.cid]
      situation = new SituationView @options.get_options
        model: model
        el: $ config.situation_template
      @situations[model.cid] = situation

    return @situations[model.cid]

  # Run any before-enter handlers on the situation.
  run_before_entering: (situation) ->
    model = situation.model
    before = model.get('before_enter')
    if _.isFunction before
      before situation.options
    @dispatcher.trigger 'before-enter', situation

  # Run any after-enter handlers on the situation.
  run_after_entering: (situation) ->
    model = situation.model
    after = model.get('after_enter')
    if _.isFunction after
      after situation.options
    @dispatcher.trigger 'after-enter', situation

  # Run any before-exit handlers on the situation.
  run_before_exiting: (situation) ->
    model = situation.model
    before = model.get('before_exit')
    if _.isFunction before
      before situation.options
    @dispatcher.trigger 'after-exit', situation

  # Run any after-exit handlers on the situation.
  run_after_exiting: (situation) ->
    model = situation.model
    after = model.get('after_exit')
    if _.isFunction after
      after situation.options
    @dispatcher.trigger 'after-exit', situation

  # Deactivate all displayed situations.
  deactivate_all: ->
    @collection.forEach (model) =>
      situation = @get_situation_from_model model
      @deactivate_situation(situation)

  # Deactivate the given situation view.
  deactivate_situation: (situation) ->
    @dispatcher.trigger 'deactivate:situation', situation

  # Activate the given situation view.
  activate_situation: (situation) ->
    @dispatcher.trigger 'activate:situation', situation

  # Activate the situation view at the top of the stack.
  reactivate_latest: ->
    model = @collection.last()
    situation = @get_situation_from_model model
    @activate_situation(situation)

  # Trigger the visual addition of a situation view that has been hidden or newly added.
  show_situation: (situation) ->
    duration = config.base_animation_duration
    trigger = @dispatcher.blackboard.get('last-trigger')
    @dispatcher.trigger "show:situation", situation.$el, trigger
    # We want to make sure that the situation is always revealed, even if no
    # effect has been defined. Show the situation after the configured default
    # animation duration, no matter what.
    _.delay((() -> situation.$el.show()), duration)

  # Trigger the visual removal effect (if any) for a situation view. If no
  # effect is defined, this will not do anything.
  remove_situation: (situation) ->
    trigger = @dispatcher.blackboard.get('last-trigger')
    @dispatcher.trigger "remove:situation", situation.$el, trigger

  # Visually push a new situation onto the stack.
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

  # Visually pop the top situation off the stack.
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

  # Stack event handlers
  # --------------------
  #
  # Respond to a situation being pushed onto the stack.
  on_push: (model, data) =>
    @push model, data

  # Respond to a situation replacing the top situation on the stack.
  on_replace: (popped, pushed, data) =>
    data.reactivate = false
    @pop popped, data
    @push pushed, data

  # Respond to a situation being popped off the top of the stack.
  on_pop: (model, data) =>
    @pop model, data

  # Respond to a complete reset of the stack.
  on_reset: () =>
    for cid, situation of @situations
      situation.remove()
    @situations = {}


# Situation View
# --------------
#
# A Situation View handles the display of a single Situation.
#
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
      D.get_context(),
      @model.toJSON(),
      extra_context)
    return context

  render_markdown: (text) ->
    return marked text, {renderer: D.markdown}

  render_template: (template, prepend) ->
    context = @get_context()
    result = template context
    if not _.isUndefined(prepend)
      result = "#{prepend}#{result}"
    html = @render_markdown result
    return $ html

  render: (prepend) ->
    context = @get_context()
    @$el.html ''
    @$el.attr('id', @model.get('id'))

    if @model.get('closeable')
      $header = $ as_template(config.situation_header_template) context
      @$el.append $header

    @body = $ as_template(config.situation_body_template) context
    rendered = @render_template @model.template, prepend

    # Process internal links to override default behavior
    rendered.find('a').not('.raw').each (idx, el) ->
      $el = $ el
      href = $el.attr('href')
      $el.data 'href', href
      $el.attr('href', 'javascript:void(0)')

    # Raw links should open in a new tab or window
    rendered.find('a.raw').each (idx, el) ->
      $el = $ el
      $el.attr('target', '_blank')
    @body.html(rendered)
    @$el.append @body

    choices = @model.get('choices')
    if choices
      if _.isFunction choices
        choices = choices()
      $footer = $ as_template(config.situation_footer_template) context
      @$el.append $footer
      $choices = $ as_template(config.situation_choices_template) context

      choice_template = as_template config.situation_choice_template

      for text, directive of choices
        text = as_template(text) context
        text = _.trimRight(text)
        if not _.isString directive
          id = directive.get('id')
          action = config.default_action
          directive = "#{action}!#{id}"
        # If the choice text ends with /... or /...., prepend it to
        # the next situation.
        if text.match /\/(\.\.\.|…).?$/
          # If the choice text ends with /.... (four dots), prepend it with a
          # newline.
          prepend_newline = text.match /\/(\.\.\.|…)\./
          text = _.trimRight(_.trimRight(text, '.'), '/')
          # If the text has [optional text] in square brackets, the optional
          # text goes in the choice, and the text following that is prepended
          # in the next situation.
          optional_p = /^(.+?)\[(.*?)\](.*)$/
          matched = text.match optional_p
          if matched
            prepend_text = matched[1] + matched[3]
            anchor_text = matched[1] + matched[2]
          else
            prepend_text = anchor_text = text
        else
          anchor_text = text
          prepend_text = ''
          prepend_newline = false
        html = @render_markdown anchor_text
        choice_context = _.extend {}, {directive: directive, html: html}, context
        $choice = $ choice_template choice_context
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

  handle_action: (event, data) ->
    actions = @model.get('actions')
    action = actions[event]
    result = action(data)
    if _.isString result
      @write result

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
        data.from_view = this
        data.from_model = @model

        if @is_action event
          @handle_action event, data
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

    else if directive == '-->'
      data.event = config.default_action
      index = D.situations.indexOf(@model)
      data.target = D.situations.at(index + 1).get('id')

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
    @rng = new Ring(seed)

    @dispatcher.on "all", () =>
      console.log "Action dispatched:", arguments

    @dispatcher.on "begin", () =>
      begin_id = @options.begin_situation || 'begin'
      @push {target: begin_id}



    @dispatcher.on "replace", @replace

    @dispatcher.on "push", @push

    @dispatcher.on "pop", @pop

    @dispatcher.on "drop", @drop

    @dispatcher.on "clear", @clear

  config: config
  next: '-->'
  markdown: new marked.Renderer()

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
      situation = @situations.get situation_id.toLowerCase()
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

  drop: (data) =>
    @stack.remove data.from_model
    @stack.trigger 'pop', data.from_model, data

  clear: (data) =>
    @stack.reset()
    @stack.trigger 'clear', data.from_model, data
    @push(data)

  replace: (data) =>
    if _.isString(data)
      situation_id = data
      data = {target: situation_id}
    else
      situation_id = data.target
    popped = @stack.pop()
    situation = @situations.get situation_id.toLowerCase()
    @stack.push situation
    @stack.trigger 'replace', popped, situation, data
    return [popped, situation]

  get_context: (extra_context) ->
    options = @get_options()
    context = _.extend(
      {},
      {
        world: options.world.attributes
        items: options.items
      },
      extra_context)
    @dispatcher.trigger 'set-template-context', context
    return context

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

    options = _.extend {}, @options, options, suboptions
    @dispatcher.trigger 'set-options', options
    return options

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


# We'll also make `one_of` available as a helper inside of Handlebar
# templates:
Handlebars.registerHelper 'one_of', D.one_of



# [backbone]: <http://backbonejs.org/>
# [backbone-events]: http://backbonejs.org/#Events
# [coffee]: <http://coffeescript.org/>
# [coffee-class]: <http://coffeescript.org/#classes>
# [coffee-initialize]: <http://backbonejs.org/#Model-constructor>
# [collections]: <http://backbonejs.org/#Collection>
# [collection-add]: http://backbonejs.org/#Collection-add
# [effects]: ./effects.html
# [fat-arrow]: http://coffeescript.org/#fat-arrow
# [handlebars]: http://handlebarsjs.com/
# [intro]: ./index.html
# [main]: ./main.html
# [jquery]: <http://jquery.com/>
# [lodash]: <https://lodash.com>
# [loose-coupling]: https://en.wikipedia.org/wiki/Loose_coupling
# [markdown]: <http://daringfireball.net/projects/markdown/syntax>
# [marked-options]: https://github.com/chjj/marked#usage
# [models]: <http://backbonejs.org/#Model>
# [_templates]: https://lodash.com/docs#template
# [view-dom-event-handlers]: http://backbonejs.org/#View-delegateEvents
# [views]: http://backbonejs.org/#View
# [with-statement]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/with
