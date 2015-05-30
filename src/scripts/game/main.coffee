$ = require('jquery')
D = require('../dreamhorn')
require('./cloak')
require('./job')


D.situation 'begin',
  content: """

  ## Starting out with Dreamhorn

  Welcome to the Dreamhorn demo. Dreamhorn provides tools for writing
  interactive hypertexts, with various styles of interaction. When it succeeds,
  it succeeds by making simple things easy, and complex things possible.

  """

  choices:
    "Play 'Cloak of Darkness', the standard IF demo": 'replace!cloak:begin'
    "Have a chat with a man about a job": 'replace!job:begin'
    "Experiment with inputs": 'push!input-test'


D.situation 'input-test',
  content: """

    This is a test of the input system.

    <input name="something" />

    <textarea name="some-long-text"></textarea>


    And here is some more text. A new paragraph?
    """
