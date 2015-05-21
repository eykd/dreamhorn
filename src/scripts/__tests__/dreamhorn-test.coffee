D = require '../dreamhorn'
assert = require('assert')
should = require('should')


describe 'Dreamhorn', ->
  describe '#situation()', ->
    it 'registers a new situation by ID', ->
      sit = D.situation 'test-by-id',
        content: 'test by ID'
      sit.should.be.an.instanceof(D.Situation)
      got = D.situations.get('test-by-id')
      got.attributes.should.equal(sit.attributes)
      got.get('content').should.equal('test by ID')

    it 'registers a new situation by on-board ID', ->
      sit = D.situation
        id: 'test-by-on-board-id'
        content: 'test by on-board ID'
      sit.should.be.an.instanceof(D.Situation)
      got = D.situations.get('test-by-on-board-id')
      got.attributes.should.equal(sit.attributes)
      got.get('content').should.equal('test by on-board ID')

    it 'should throw an error when no ID provided', ->
      assert.throws((->
        D.situation
          content: "foo"
      ), Error, "No ID provided with new situation!")

  describe '#push()', ->
    it 'pushes a new situation ID', ->
