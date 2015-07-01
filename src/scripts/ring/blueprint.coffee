Ring = require('./core')
Card = require('./card')
_ = require('lodash')


class Blueprint
  constructor: (@rng) ->
    @cache = {}

  make_type: Card

  export_attributes: []

  get: (name) ->
    if name of @cache
      return @cache[name]

    value = this[name]
    if _.isFunction value
      value = value.apply(this)

    @cache[name] = value
    return value


Blueprint.generate = (rng, options) ->
  if _.isUndefined rng
    if not _.isUndefined this.rng
      rng = this.rng.subgen()
    else
      rng = new Ring()

  if _.isUndefined options
    options = {}

  bp = new this(rng)

  # If `make_type` is a Card, or extends Card, make a new one.
  if Card.prototype.isPrototypeOf(bp.make_type.prototype)
    result = new bp.make_type()
  # Otherwise, it should be a function that returns an instantiated object.
  else
    result = bp.make_type()

  for name in bp.export_attributes
    if name of options
      result[name] = options[name]
    else
      result[name] = bp.get name

  return result

D.Blueprint = Blueprint

module.exports = Blueprint
