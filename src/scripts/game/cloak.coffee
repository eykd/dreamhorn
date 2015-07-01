$ = require('jquery')
D = require('../dreamhorn')


D.situation 'cloak:begin',
  before_enter: (options) ->
    options.world.set 'wearing cloak', true

  content: """

  Hurrying through the rainswept November night, you're glad to see the bright
  lights of the Opera House. It's surprising that there aren't more people
  about but, hey, what do you expect in a cheap demo game...?

  [Onward!](push!cloak:rooms:foyer)

  <div class="row">
  <p class="col-md-6 col-md-offset-6">
    <small><em>Cloak of Darkness &copy; <a href="http://www.firthworks.com/roger/cloak/">Roger Firth</a>;
    sloppily adapted by David Eyk.</em></small>
  </p>
  </div>


  """


D.situation 'cloak:rooms:outside',
  classes: "card-warning"
  content: """

  You've only just arrived, and besides, the weather outside seems to be
  getting worse. Best to [stay inside](pop!)

  """


D.situation 'cloak:rooms:foyer',
  content: """

  ## Foyer of the Opera House

  You are standing in a spacious hall, splendidly decorated in red and gold,
  with glittering chandeliers overhead. The entrance from the street is to the
  [north](push!cloak:rooms:outside), and there are doorways [south](push!cloak:rooms:bar) and
  [west](push!cloak:rooms:cloakroom).

  """
  choices:
    "Leave the Opera House by the north entrance": "push!cloak:rooms:outside"
    "Go South to the Bar": "push!cloak:rooms:bar"
    "Go West to the Cloak Room": "push!cloak:rooms:cloakroom"


D.situation 'cloak:rooms:cloakroom',
  content: """

  ## Cloakroom

  The walls of this small room were clearly once lined with hooks,
  though now only [one](push!cloak:items:hook) remains. The exit is a door to
  the [east](pop!).


  """


D.situation 'cloak:rooms:bar',
  content: """

  {{#if world.[wearing cloak]}}

  ## Darkness

  It is pitch dark, and you can't see a thing. You could
  [back out slowly](!) or [fumble around for a light](!).

  {{else}}

  ## Foyer Bar

  The bar, much rougher than you'd have guessed after the opulence of
  the foyer to the north, is completely empty. There seems to be some
  sort of [message](!) scrawled in the sawdust on the floor.

  {{/if}}

  """
  actions:
    'back out slowly': ->
      D.pop()

    'fumble around for a light': ->
      D.push 'cloak:actions:fumble around'

    'message': ->
      D.push 'cloak:items:message'


D.situation 'cloak:actions:fumble around',
  content: """

    You fumble around in the dark, but to no avail.

    """

  choices:
    "Continue...": "pop!"
  before_enter: ->
    D.world.set('fumbled', true)


D.situation 'cloak:items:hook',
  content: """

  ## The hook

  It's just a small brass hook, screwed to the wall.
  <% if (world['wearing cloak']) { %>
  Useful for [hanging things](!) on it.
  <% } else { %>
  Your [opera cloak](!) is hanging on it.
  <% } %>

  """
  choices:
    "Continue...": "pop!"
  actions:
    "hanging things": ->
      D.world.set('wearing cloak', false)
      return "You hang the velvet cloak on the hook."

    "opera cloak": ->
      return "You take the velvet cloak off the hook and put it on."


D.situation 'cloak:items:message',
  content: """

  <% if (world['fumbled']) { %>
  ## A message?

  There appears to have been a message marked here in the sawdust, but someone
  must have blundered through it in the dark. As best as you can tell, it reads...

  **You have lost**

  <% } else { %>
  ## The message

  The message, neatly marked in the sawdust, reads...

  **You have won**

  <% } %>

  [Start over.](reset!)

  """


D.situation 'cloak:actions:hang up cloak',
  content: """

    You put the velvet cloak on the small brass hook.

    <% world.set("wearing cloak", False) %>

    """
  choices:
    "Continue...": "pop!"
