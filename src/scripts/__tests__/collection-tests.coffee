D = require '../dreamhorn'
assert = require('assert')


describe 'base-Collection', ->
  describe '#constructor()', ->
    it 'sets up the dispatcher', ->
      model = new D.Collection([], {dispatcher: 'test'})
      assert.equal(model.dispatcher, 'test')
