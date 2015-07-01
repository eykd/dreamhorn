Ring = require('./core')
_ = require('lodash')
Owlbear = require('owlbear')

parser = new Owlbear()


# Roll dice using standard dice notation.
Ring.prototype.roll = (dexpr) ->
  console.log "Roll:", dexpr
  if _.isString dexpr
    rolls = parser.parse(dexpr)
  else
    rolls = Array.prototype.slice.apply(arguments)

  all_results = []
  console.log "Parsed:", rolls
  for roll in rolls
    if 'operator' of roll
      all_results.push roll.operator
    else if 'constant' of roll
      all_results.push roll.constant
    else
      count = roll.count || 1
      keep = roll.keep
      die = roll.die || {}
      sides = die.sides || 6
      reroll = die.reroll || []
      explode = die.explode || []

      results = []
      opts = {min: 1, max: sides}
      for r in [0..count-1]
        result = @integer opts

        # Handle re-rolls
        while result in reroll
          result = @integer opts
        results.push result

        # Handle exploding dice
        while result in explode
          result = @integer opts
          results.push result

      if _.isFinite(keep) and keep < results.length
        results.sort()
        results.reverse()
        results = results.slice 0, keep

      all_results.push _.sum results

  expr = all_results.join(' ')
  console.log "Eval expr:", expr, all_results
  final = eval expr
  console.log "Final result:", final
  return final

    

# Roll Fudge dice, returning the sum.
# If no number of dice is specified, roll 4.
fudge_dice = Ring.prototype.dF = (num) ->
  num = num || 4
  return _.sum @pick(fudge_dice.sides) for n in [0..num]

fudge_dice.sides = [-1, -1, 0, 0, 1, 1]
