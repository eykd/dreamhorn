'use strict';

$ = require('jquery')
dreamhorn = require('./dreamhorn')
require('./effects')

dreamhorn.situation 'begin',
  before: (options) ->
    options.world.set 'wearing cloak', true

  content: """

  Hurrying through the rainswept November night, you're glad to see the bright
  lights of the Opera House. It's surprising that there aren't more people
  about but, hey, what do you expect in a cheap demo game...?

  [Onward!](replace!rooms:foyer)

  """

dreamhorn.situation 'rooms:outside',
  content: """

  You've only just arrived, and besides, the weather outside seems to be
  getting worse. Best to [stay inside](replace!rooms:foyer)

  """

dreamhorn.situation 'rooms:foyer',
  content: """

  ## Foyer of the Opera House

  You are standing in a spacious hall, splendidly decorated in red and gold,
  with glittering chandeliers overhead. The entrance from the street is to the
  [north](replace!rooms:outside), and there are doorways [south](replace!rooms:bar) and
  [west](replace!rooms:cloakroom).

  """

dreamhorn.situation 'rooms:cloakroom',
  content: """

  ## Cloakroom

  The walls of this small room were clearly once lined with hooks,
  though now only [one](push!items:hook) remains. The exit is a door to
  the [east](replace!rooms:foyer).


  """

dreamhorn.situation 'rooms:bar',
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
