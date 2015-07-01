# Based on https:#github.com/forana/darmok-js/blob/development/src/markov.js
"use strict"

assert = require("assert")
_ = require("lodash")
Ring = require("./core")
require('./weighted_choice')

START = "START"
END = "END"

init_trail = (length) ->
  trail = []
  while (trail.length < length)
    trail.push START
  return trail


Ring.train_markov_chain = (corpus, lookback) ->
  lookback_distance = lookback + 1
  assert(corpus.length > 0)
  assert(lookback_distance > 0)
  assert(Math.floor(lookback_distance) == lookback_distance)

  matrix =
    sum: 0
    children: {}

  # add each training item to the matrix
  _.each corpus, (raw_item) ->
    trail = init_trail(lookback_distance)

    item = raw_item.split("")
    item.push(END)

    _.each item, (letter) ->
      trail.push(letter)

      while (trail.length > lookback_distance)
        trail = trail.splice(1)

      # dive into matrix, create path along the way
      matrix.sum += 1
      dive = matrix

      _.each trail, (part) ->
        if not dive.children
          dive.children = {}

        if not dive.children.hasOwnProperty(part)
          new_segment =
            sum: 1
          dive.children[part] = new_segment
          dive = new_segment
        else
          segment = dive.children[part]
          segment.sum += 1
          dive = segment

  return {
    matrix: matrix
    lookback: lookback_distance
  }

Ring.prototype.get_markov_generator = (options) ->
  return new Generator this, options


class Generator
  constructor: (@rng, {matrix: @matrix, lookback: @lookback}) ->

  generate: (max_length) ->
    trail = init_trail(@lookback)
    selections = []

    graceful = false
    while (selections.length < max_length || !max_length)
      # trim the trail
      while (trail.length > @lookback - 1)
        trail = trail.splice(1)

      # navigate the matrix
      dive = @matrix
      _.each trail, (part) ->
        dive = dive.children[part]

      # extract sums and values for choice
      values = []
      sums = []
      _.each dive.children, (value, key) ->
        values.push(key)
        sums.push(value.sum)

      # make choice
      choice = @rng.weighted_choice(values, sums)
      # if it's the end keyword, call the word over - otherwise add and continue
      if (choice == END)
        graceful = true
        break
      else
        selections.push(choice)
        trail.push(choice)

    return selections.join("")
