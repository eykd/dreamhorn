D = require '../dreamhorn'
assert = require('assert')
should = require('should')


describe 'base-Model', ->
  describe '#constructor()', ->
    it 'sets up the dispatcher', ->
      model = new D.Model([], {dispatcher: 'test'})
      assert.equal(model.dispatcher, 'test')


describe 'Situation-Model', ->
  describe '#initialize()', ->
    it 'creates a template', ->
      sit = new D.Situation({content: 'test'})
      sit.template().should.equal('test')
