MersenneTwister = require('mersenne-twister')
_ = require('lodash')


# Constants
MAX_INT = 9007199254740992
MIN_INT = -MAX_INT
NUMBERS = '0123456789'
CHARS_LOWER = 'abcdefghijklmnopqrstuvwxyz'
CHARS_UPPER = CHARS_LOWER.toUpperCase()
HEX_POOL  = NUMBERS + "abcdef"

test_range = (test, errorMessage) ->
  if test
    throw new RangeError(errorMessage)


class Ring
  constructor: (seed) ->
    @seed = seed
    @twister = new MersenneTwister(seed)

  subgen: () ->
    return new Ring @twister.random_int()

  random: () ->
    return @twister.random()

  random_int: () ->
    return @twister.random_int()

  random_incl: () ->
    return @twister.random_incl()

  random_excl: () ->
    return @twister.random_excl()

  random_long: () ->
    return @twister.random_long()

  random_int31: () ->
    return @twister.random_int31()

   # Return a random integer
   #
   # NOTE the max and min are INCLUDED in the range. So:
   # ring.integer({min: 1, max: 3});
   # would return either 1, 2, or 3.
   #
   # @param {Object} [options={}] can specify a min and/or max
   # @returns {Number} a single random integer number
   # @throws {RangeError} min cannot be greater than max
  integer: (options) ->
    # 9007199254740992 (2^53) is the max integer number in JavaScript
    # See: http://vq.io/132sa2j
    options = _.extend {min: MIN_INT, max: MAX_INT}, options
    test_range(options.min > options.max, "Ring: Min cannot be greater than Max.");

    return Math.floor(@random() * (options.max - options.min + 1) + options.min);

  # Return a random natural
  #
  # NOTE the max and min are INCLUDED in the range. So:
  # ring.natural({min: 1, max: 3});
  # would return either 1, 2, or 3.
  #
  # @param {Object} [options={}] can specify a min and/or max
  # @returns {Number} a single random integer number
  # @throws {RangeError} min cannot be greater than max
  natural: (options) ->
    options = _.extend {min: 0, max: MAX_INT}, options
    test_range(options.min < 0, "Ring: Min cannot be less than zero.")
    return this.integer(options);

  pick: (arr, count) ->
    test_range arr.length == 0, "Ring: Cannot pick() from an empty array"

    if (!count || count == 1)
      return arr[@natural({max: arr.length - 1})];
    else
      return @shuffle(arr).slice(0, count);

  shuffle: (arr) ->
    old_array = arr.slice(0)
    new_array = []
    j = 0
    length = Number(old_array.length)

    for i in [0..length]
      # Pick a random index from the array
      j = @natural {max: old_array.length - 1}
      # Add it to the new array
      new_array[i] = old_array[j]
      # Remove that element from the original array
      old_array.splice j, 1

    return new_array


module.exports = Ring
