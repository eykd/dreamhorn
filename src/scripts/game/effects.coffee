'use strict';

_ = require('lodash')
ramjet = require('ramjet')

D = require('../dreamhorn')

DURATION = D.config.effects.base_animation_duration

$.Velocity.RegisterEffect 'transition.enter',
  defaultDuration: DURATION * 3
  calls: [
    [{height: 0}, 0.0],
    [{height: '100%'}, 0.33],
    ['transition.expandIn', 0.33, {delay: DURATION}],
    ['scroll', 0.33],
  ]


make_invisible = ($el) ->
  $el.css({visibility: 'hidden'}).show()


D.dispatcher.on "expand:title", ($el) ->
  $el.hide()
     .removeClass('page-header')
     .addClass('jumbotron')
     .velocity('fadeIn', DURATION * 2)
  $.Velocity $('#footer').get(0), 'transition.expandIn',
    duration: DURATION


D.dispatcher.on "reduce:title", ($el) ->
  container = $el.parent()
  container.height $el.outerHeight(true)
  el = $el.get 0
  $.Velocity(el, 'transition.expandOut', {visibility: "hidden", duration: DURATION / 2})
    .then ->
      $el.removeClass 'jumbotron'
         .addClass 'page-header'
      $.Velocity(el, 'transition.expandIn', {visibility: "visible", duration: DURATION / 2})
        .then ->
          $.Velocity(container, {'height': $el.height()}, {duration: DURATION / 2})
            .then ->
              container.height('auto')
  $.Velocity $('#footer').get(0), 'transition.expandOut',
    duration: DURATION


D.dispatcher.on "show:begin-button", ($el) ->
  $el.velocity(
    'transition.expandIn',
    {visibility: "visible", duration: DURATION, delay: 100})


D.dispatcher.on "remove:begin-button", ($el) ->
  $.Velocity($el.get(0), 'transition.expandOut', {duration: DURATION / 2}).then ->
    $el.remove()


D.dispatcher.on "show:situation", ($el, $trigger) ->
  make_invisible($el)
  sequence = [
    {
      e: $el, p: {height: 0},
      o: {display: 'block', visibility: 'hidden', duration: 0}},
    {
      e: $el, p: {height: '100%'},
      o: {duration: DURATION / 3}},
    {
      e: $el, p: 'scroll',
      o: {duration: DURATION, sequenceQueue: false}},
    {
      e: $el, p: 'transition.bounceLeftIn',
      o: {visibility: "visible", duration: DURATION, sequenceQueue: false}},
  ]
  $.Velocity.RunSequence(sequence)


D.dispatcher.on "remove:situation", ($el, $trigger) ->
  sequence = [
    {
      e: $el, p: 'transition.bounceRightOut',
      o: {visibility: "hidden", display: null, duration: DURATION}
      },
    {
      e: $el, p: {height: 0},
      o: {display: "none", duration: DURATION}
      },
  ]
  $.Velocity.RunSequence(sequence)


D.dispatcher.on "deactivate:situation", (situation) ->
  situation.unlink()
  situation.$('.card-footer').velocity 'slideUp',
    duration: DURATION


D.dispatcher.on "activate:situation", (situation) ->
  situation.relink()
  situation.$('.card-footer').velocity 'slideDown',
    duration: DURATION
