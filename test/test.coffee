# build time tests for search plugin
# see http://mochajs.org/

search = require '../client/search'
expect = require 'expect.js'

describe 'search plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = search.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'
