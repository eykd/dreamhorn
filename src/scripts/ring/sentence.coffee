"use strict"

_ = require("lodash")
assert = require("assert")
Handlebars = require("handlebars")
Ring = require("./core")
require('./weighted_choice')

Ring.train_sentence_generator = (sentence_frames, categories) ->
    assert(_.keys(sentence_frames).length > 0, "Must give at least one sentence frame")
    probs = []
    frames = []
    _.each(sentence_frames, (prob, frame) ->
        probs.push(prob)
        frames.push(Handlebars.compile(frame))
    )

    return {frames: frames, probs: probs, categories: categories}

Ring.prototype.get_sentence_generator = (training_data) ->
  return new Generator(this, training_data)


class Generator
  constructor: (@rng, {frames: @frames, probs: @probs, categories: @categories}) ->

  generate: () ->
    frame = @rng.weighted_choice(@frames, @probs)
    words = {}
    _.each @categories, (word_list, category) =>
      words[category] = @rng.pick(word_list)

    return frame(words)
