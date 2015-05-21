D = require '../dreamhorn'
assert = require('assert')
should = require('should')


describe 'SituationView', ->
  view = new D.SituationView({})

  describe '#parse_directive(text, directive)', ->
    it 'parses "!"', ->
      view.parse_directive('Foo', '!').should.eql(['foo', 'foo'])

    it 'parses "!event"', ->
      view.parse_directive('Foo', '!event').should.eql(['event', 'foo'])

    it 'parses "action!event"', ->
      view.parse_directive('Foo', 'action!arg').should.eql(['action', 'arg'])
