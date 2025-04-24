// build time tests for search plugin
// see http://mochajs.org/

import { search } from '../client/search'
import expect from 'expect.js'

describe('search plugin', () => {
  describe('expand', () => {
    it('can make itallic', () => {
      const result = search.expand('hello *world*')
      expect(result).to.be('hello <i>world</i>')
    })
  })
})
