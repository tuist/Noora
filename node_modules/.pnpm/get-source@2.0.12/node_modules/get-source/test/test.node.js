"use strict";

/*  NOTE: I've used supervisor to auto-restart mocha, because mocha --watch
          didn't work for selenium tests (not reloading them)...
          ------------------------------------------------------------------ */
                    
require ('chai').should ()

/*  ------------------------------------------------------------------------ */

describe ('get-source', () => {

    const getSource = require ('../get-source'),
          fs        = require ('fs'),
          path      = require ('path')

    it ('cache sanity check', () => {

        getSource ('./get-source.js').should.equal     (getSource ('./get-source.js'))
        getSource ('./get-source.js').should.not.equal (getSource ('./package.json'))
    })

    it ('reads sources (not sourcemapped)', () => {

        const original = getSource ('./test/files/original.js')

        original.path.should.equal (path.resolve ('./test/files/original.js')) // resolves input paths
        original.text.should.equal (fs.readFileSync ('./test/files/original.js', { encoding: 'utf-8' }))
        original.lines.should.deep.equal ([
            '/*\tDummy javascript file\t*/',
            '',
            'function hello () {',
            '\treturn \'hello world\' }'
        ])

        const resolved = original.resolve ({ line: 4, column: 1 })

        resolved.line.should.equal (4)
        resolved.column.should.equal (1)
        resolved.sourceFile.should.equal (original)
        resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
    })

    it ('reads sources (sourcemapped, with external links)', () => {

        const uglified = getSource ('./test/files/original.uglified.js')

        uglified.path.should.equal (path.resolve ('./test/files/original.uglified.js'))
        uglified.lines.should.deep.equal ([
            'function hello(){return"hello world"}',
            '//# sourceMappingURL=original.uglified.js.map',
            ''
        ])

        // uglified.sourceMap.should.not.equal (undefined)
        // uglified.sourceMap.should.equal (uglified.sourceMap) // memoization should work

        const resolved = uglified.resolve ({ line: 1, column: 18 }) // should be tolerant to column omission

        resolved.line.should.equal (4)
        resolved.column.should.equal (2)
        resolved.sourceFile.should.equal (getSource ('./test/files/original.js'))
        resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
    })

    it ('reads sources (sourcemapped, with external links) — ASYNC', () => {

        const uglified = getSource.async ('./test/files/original.uglified.js')

        return uglified.then (uglified => {

            uglified.path.should.equal (path.resolve ('./test/files/original.uglified.js'))
            uglified.lines.should.deep.equal ([
                'function hello(){return"hello world"}',
                '//# sourceMappingURL=original.uglified.js.map',
                ''
            ])
    
            // uglified.sourceMap.should.not.equal (undefined)
            // uglified.sourceMap.should.equal (uglified.sourceMap) // memoization should work
    
            return uglified.resolve ({ line: 1, column: 18 }).then (resolved => {
        
                return getSource.async ('./test/files/original.js').then (originalFile => {
                    resolved.line.should.equal (4)
                    resolved.column.should.equal (2)
                    resolved.sourceFile.should.equal (originalFile)
                    resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
                })
            })
        })
    })

    it ('reads sources (sourcemapped, with embedded sources)', () => {

        const uglified = getSource ('./test/files/original.uglified.with.sources.js')

        uglified.path.should.equal (path.resolve ('./test/files/original.uglified.with.sources.js'))
        uglified.lines.should.deep.equal ([
            'function hello(){return"hello world"}',
            '//# sourceMappingURL=original.uglified.with.sources.js.map',
            ''
        ])

        // uglified.sourceMap.should.not.equal (undefined)

        const resolved = uglified.resolve ({ line: 1, column: 18 })

        resolved.line.should.equal (4)
        resolved.column.should.equal (2)
        resolved.sourceFile.path.should.equal (path.resolve ('./test/files') + '/## embedded ##') // I've changed the filename manually, by editing .map file
        resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
    })

    it ('reads sources (sourcemapped, with inline base64 sourcemaps)', () => {

        const babeled = getSource ('./test/files/original.babeled.with.inline.sourcemap.js')

        // babeled.sourceMap.should.not.equal (undefined)
        // babeled.sourceMap.file.path.should.equal (babeled.path)

        const resolved = babeled.resolve ({ line: 6, column: 1 })

        resolved.line.should.equal (4)
        resolved.column.should.equal (2)
        resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
    })

    it ('supports even CHAINED sourcemaps!', () => {

    /*  original.js → original.uglified.js → original.uglified.beautified.js    */

        const beautified = getSource ('./test/files/original.uglified.beautified.js')

        beautified.path.should.equal (path.resolve ('./test/files/original.uglified.beautified.js'))
        beautified.text.should.equal (fs.readFileSync ('./test/files/original.uglified.beautified.js', { encoding: 'utf-8' }))

        // beautified.sourceMap.should.not.equal (undefined)

        const resolved = beautified.resolve ({ line: 2, column: 4 })

        resolved.line.should.equal (4)
        resolved.column.should.equal (2)
        resolved.sourceFile.path.should.equal (path.resolve ('./test/files/original.js'))
        resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
    })

    it ('adheres to async interface', () => {
    
        return getSource.async ('./get-source.js').then (result => {

            ;(result.resolve ({ line: 1, column: 0 }) instanceof Promise).should.equal (true)
        })
    })

    it ('supports even CHAINED sourcemaps! — ASYNC', () => {

        /*  original.js → original.uglified.js → original.uglified.beautified.js    */
    
        return getSource.async ('./test/files/original.uglified.beautified.js').then (beautified => {

            beautified.text.should.equal (fs.readFileSync ('./test/files/original.uglified.beautified.js', { encoding: 'utf-8' }))
            beautified.path.should.equal (path.resolve ('./test/files/original.uglified.beautified.js'))

            return beautified.resolve ({ line: 2, column: 4 }).then (resolved => {

                resolved.line.should.equal (4)
                resolved.column.should.equal (2)
                resolved.sourceFile.path.should.equal (path.resolve ('./test/files/original.js'))
                resolved.sourceLine.should.equal ('\treturn \'hello world\' }')
            })
        })
    })

    it ('does some error handling', () => {

        const nonsense = getSource ('abyrvalg')

        nonsense.text.should.equal ('')
        nonsense.error.should.be.an.instanceof (Error)

        const resolved = nonsense.resolve ({ line: 5, column: 0 })

        resolved.error.should.equal (nonsense.error)
        resolved.sourceLine.should.equal ('')
        resolved.sourceFile.path.should.equal ('abyrvalg')
    })

    it ('does some error handling - ASYNC', () => {

        return getSource.async ('abyrvalg').then (x => { console.log (x) }).catch (error => {
            error.should.be.an.instanceof (Error)
        })
    })

    it ('allows absolute paths', () => {

        getSource (require ('path').resolve ('./get-source.js')).should.equal (getSource ('./get-source.js'))
    })

    it ('caching works', () => {
        
        const files =
                [   './get-source.js',
                    './package.json',
                    './test/files/original.js',
                    './test/files/original.uglified.js',
                    './test/files/original.uglified.js.map',
                    './test/files/original.uglified.with.sources.js',
                    './test/files/original.uglified.with.sources.js.map',
                    './test/files/original.babeled.with.inline.sourcemap.js',
                    './test/files/original.uglified.beautified.js',
                    './test/files/original.uglified.beautified.js.map',
                    './abyrvalg' ]
            
        Object.keys (getSource.getCache ()).should.deep.equal (files.map (x => path.resolve (x)))

        getSource.resetCache ()

        Object.keys (getSource.getCache ()).length.should.equal (0)
    })
})