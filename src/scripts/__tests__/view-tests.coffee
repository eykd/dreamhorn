D = require '../dreamhorn'
assert = require('assert')


describe 'base-View', ->
  describe '#constructor()', ->
    it 'sets up the dispatcher', ->
      view = new D.View({dispatcher: 'test'})
      assert.equal(view.dispatcher, 'test')
