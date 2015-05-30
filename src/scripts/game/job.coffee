$ = require('jquery')
_ = require('lodash')
D = require('../dreamhorn')


party = D.party = new D.Characters()
gang = D.gang = new D.Characters()

setup_characters = () ->
  # Set up our hero's party. We have a leader, a lieutenant, and some muscle:
  for role in ['ldr', 'ltn', 'msc']
    do (role) ->
      sex = D.chance.gender()
      party.add
        id: role
        sex: sex
        first: D.chance.first({gender: sex})
        last: D.chance.last()


  # Set up the gang. One boss and five heavies.
  for role in ['boss', 'hv1', 'hv2', 'hv3', 'hv4', 'hv5']
    do (role) ->
      gang.add
        id: role
        sex: 'Male'
        first: D.chance.first({gender: 'Male'})
        last: D.chance.last()

setup_characters()

D.dispatcher.on 'reset', ->
  D.party.reset []
  D.gang.reset []
  setup_characters()


D.dispatcher.on 'set-template-imports', (imports) ->
  for group in [party, gang]
    do (group) ->
      group.forEach (char) ->
        imports[char.get('id')] = char.attributes


D.situation 'job:begin',
  before_enter: () ->

  content: """

    ## <<boss.plast>> Den

    The three of you enter a wide, low-ceilinged room with an earthen
    floor. Sunlight filters in through a skylight, and motes of dust dance in
    the beam. <<ltn.first>> exchanges a glance with you. Five ugly men line
    the back wall, all packing heat.

    """

  choices:
    "Well fine, that's why you brought <<msc.first>>. // ": D.situation
      content: """

        <<msc.PA>> eyes narrow as <<msc.he>> sizes up the heavies in the
        back. Hopefully you won't need <<msc.him>>. The heavies likewise size
        up the three of you. No one has any illusions what will happen if you
        make the wrong move here.

        """
      choices:
        "*Forget them*[;]. // ": D.situation
          content: """

            the man you're here to talk to waits at the far end of the room,
            reclining in a chair with his feet on the desk. <<boss.first>>
            <<boss.last>>.

            """
          choices:
            "Reluctantly, you approach the desk./// ": "job:the boss"
            "Mustering all your confidence, you approach the desk./// ": "job:the boss"


D.situation 'job:the boss',
  content: """

    "You're late," says <<boss.last>>.

    """

  choices:
    """"No, we're not."/// """: '-->'
    """"Define 'late'."/// """: '-->'
    """"You're mistaken."/// """: '-->'

D.situation
  content: """

    He gives you a sharp look. "Excuse me?"

    """
  choices:
    "You lean forward, hands on the desk[.] and explain. //": '-->'
    "You point your finger at <<boss.last>>[.] and explain. //": '-->'
    "You wave your hands[.] and explain. //": '-->'


D.situation 'job:explain',
  content: """

    "You know that we landed early, with the goods, everything as agreed
    upon. But now you're getting touchy, saying we're late, putting us out in
    the cold. So I say something's wrong. Not on our end, so you tell me."

    """
  choices:
    "Let that sink in.": "job:prefer"

D.situation 'job:prefer',
  content: """

    <<boss.last>> swings his feet off the desk and leans forward. "Alright," he
    says. "You're later than I prefer."

    """
  choices:
    """"That's better."/// """: '-->'
    """"I'm so sorry to hear that."/// """: '-->'
    """"And what would you have preferred?"/// """: '-->'

D.situation
  content: """

    He stands up, picks a baseball off his desk and tosses it in his hand
    absently. "*Had* you gotten here sooner, you *might* have beaten the signal
    *detailing* the rogue vessel sighted on an illegal salvage
    operation. Details matching your own vessel, suspiciously enough."

    """
  choices:
    """*Uh-oh. Stay cool, kids.* "They didn't I.D. us.[ ]"// """: '-->'


D.situation
  content: """
     They can't trace it back to you."

    "No? You don't think an Accord serial number on every part might help?"

    <<ltn.first>> and <<msc.first>> both look at you, eyes wide.

    """
  choices:
    "...": '-->'


D.situation
  content: """

    <<boss.last>> continues. "Noticed that, didn't you? Just planning to hand
    it over, let me take the heat, were you?"

    """
  choices:
    '"Hey, it\'s your cargo."/// ': '-->'
    '"Now <<boss.last>>, you knew the cargo before you hired us."/// ': '-->'


D.situation
  content: """

    He scoffs, then sneers and slams the baseball down on the desk. "Well,
    *I'm* not the fool what stopped for pictures with the Goddamn Accord! No
    deal. Get outta here."

    <<ltn.first>> pipes up. "That's no good, <<boss.last>>. We had a deal."

    """
  choices:
    'Interrupt, before <<ltn.he>> gets us all killed.': 'job:interrupt ltn'
    'Let <<ltn.him>> say <<ltn.his_poss_adj>> piece.': 'job:let ltn continue'


D.situation 'job:interrupt ltn',
  content: """

    You decide you'd like the three of you to leave under your own power.  You
    interrupt. "*That's*, er, not exactly what we agreed on, but given the
    situation, I'll understand if you want to renegotiate."

    """

D.situation 'job:let ltn continue',
  content: """

    You could interrupt, but you let <<ltn.him>> take the
    initiative.

    <<boss.last>> doesn't feel so generous, though. "You want to take this to a
    judge, little <<pronoun(ltn, 'boy', 'girl', 'one')>>?" he says. "Didn't you
    know that crime doesn't pay?"

    """
