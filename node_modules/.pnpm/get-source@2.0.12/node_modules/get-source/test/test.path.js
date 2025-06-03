"use strict";

/*  ------------------------------------------------------------------------ */
   
require ('chai').should ()

/*  ------------------------------------------------------------------------ */

describe ('path', () => {

    const path = require ('../impl/path')

    it ('resolves', () => {

        path.resolve ('./foo/bar/../qux').should.equal (process.cwd () + '/foo/qux')
    })

    it ('normalizes', () => {

        path.normalize ('./foo/./bar/.././.././qux.map./').should.equal ('qux.map./')

        path.normalize ('/a/b').should.equal ('/a/b')
        path.normalize ('http://foo/bar').should.equal ('http://foo/bar')
    })

    it ('computes relative location', () => {

        path.relativeToFile ('/foo/bar.js', './qux.map')
              .should.equal ('/foo/qux.map')

        path.relativeToFile ('/foo/bar/baz.js', './../.././qux.map')
              .should.equal ('/qux.map')

        path.relativeToFile ('/foo/bar', 'webpack:something')
              .should.equal ('webpack:something')

        path.relativeToFile ('/foo/bar', 'web/pack:something')
              .should.equal ('/foo/web/pack:something')
    })

    it ('works with data URIs', () => {

        path.relativeToFile ('/foo/bar.js', 'data:application/json;charset=utf-8;base64,eyJ2ZXJza==')
              .should.equal (               'data:application/json;charset=utf-8;base64,eyJ2ZXJza==')

        path.relativeToFile ('data:application/json;charset=utf-8;base64,eyJ2ZXJza==', 'foo.js')
              .should.equal (                                                          'foo.js')
    })

    it ('implements isURL', () => {

        path.isURL ('foo.js').should.equal (false)
        path.isURL ('/foo/bar.js').should.equal (false)
        path.isURL ('https://google.com').should.equal (true)
    })
})