'use strict';

$ = require('jquery')
D = require('./dreamhorn')
require('./effects')

D.situation 'begin',
  before_enter: (options) ->
    options.world.set 'wearing cloak', true

  content: """

  Hurrying through the rainswept November night, you're glad to see the bright
  lights of the Opera House. It's surprising that there aren't more people
  about but, hey, what do you expect in a cheap demo game...?

  [Onward!](replace!rooms:foyer)

  """

D.situation 'rooms:outside',
  content: """

  You've only just arrived, and besides, the weather outside seems to be
  getting worse. Best to [stay inside](pop!)

  """

D.situation 'rooms:foyer',
  content: """

  ## Foyer of the Opera House

  You are standing in a spacious hall, splendidly decorated in red and gold,
  with glittering chandeliers overhead. The entrance from the street is to the
  [north](push!rooms:outside), and there are doorways [south](replace!rooms:bar) and
  [west](replace!rooms:cloakroom).

  """

D.situation 'rooms:cloakroom',
  content: """

  ## Cloakroom

  The walls of this small room were clearly once lined with hooks,
  though now only [one](push!items:hook) remains. The exit is a door to
  the [east](replace!rooms:foyer).


  """

D.situation 'rooms:bar',
  content: """

  <% if (world.get('wearing cloak')) { %>

  ## Darkness

  It is pitch dark, and you can't see a thing. You could
  [back out slowly](!) or [fumble around for a light](!).

  <% } else { %>

  ## Foyer Bar

  The bar, much rougher than you'd have guessed after the opulence of
  the foyer to the north, is completely empty. There seems to be some
  sort of [message](!) scrawled in the sawdust on the floor.

  <% } %>

  """
  actions:
    'back out slowly': ->
      D.replace 'rooms:foyer'

    'fumble around for a light': ->
      D.push 'actions:fumble around'

    'message': ->
      D.push 'items:message'


D.situation 'actions:fumble around',
  content: """

You fumble around in the dark, but to no avail.

[Continue...](pop!)

  """
  before_enter: ->
    D.world.set('fumbled', true)


D.situation 'items:hook',
  content: """

  ## The hook

  It's just a small brass hook, screwed to the wall.
  <% if (world.get('wearing cloak')) { %>
  Useful for [hanging things](!) on it.
  <% } else { %>
  Your [opera cloak](!) is hanging on it.
  <% } %>

  [Continue...](pop!)
  """
  actions:
    "hanging things": ->
      D.world.set('wearing cloak', false)
      return "You hang the velvet cloak on the hook."

    "opera cloak": ->
      return "You take the velvet cloak off the hook and put it on."


D.situation 'items:message',
  content: """

  <% if (world.get('fumbled')) { %>
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


D.situation 'actions:hang up cloak',
  content: """

  You put the velvet cloak on the small brass hook.

  {{ this.set("wearing cloak", False) }}

  [Continue...](pop!)

  """
