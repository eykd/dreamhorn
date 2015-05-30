module.exports =
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

  # Options controlling animation effect behavior:
  effects:
    base_animation_duration: 500

# [marked-options]: https://github.com/chjj/marked#usage
