"use strict";

/*  ------------------------------------------------------------------------ */

const nodeVersion = Math.floor (Number (process.version.match (/^v(\d+\.\d+)/)[1]))

/*  ------------------------------------------------------------------------ */
                    
require ('chai').should ()

/*  ------------------------------------------------------------------------ */

describe ('impl/partition', () => {

    const partition = require ('./impl/partition')
    const spans     = partition ([ 'a', 'b', 'c', undefined, undefined, 42], x => typeof x)

    spans.should.deep.equal ([ { label: 'string',    items: ['a', 'b', 'c'] },
                               { label: 'undefined', items: [undefined, undefined] },
                               { label: 'number',    items: [42] } ])
})

/*  ------------------------------------------------------------------------ */

describe ('StackTracey', () => {

    const path = require ('path')
    const StackTracey = require ('./stacktracey')
    
    StackTracey.resetCache ()

    const shouldBeVisibleInStackTrace = () => new StackTracey () // @hide

    it ('works', () => {

        const stack = shouldBeVisibleInStackTrace ()

        stack.should.be.an.instanceof (StackTracey)

        stack.items[0].should.deep.equal ({
            beforeParse: 'at shouldBeVisibleInStackTrace (' + path.join (process.cwd (), 'test.js') + ':32:47)',
            callee: 'shouldBeVisibleInStackTrace',
            index: false,
            native: false,
            file: path.join (process.cwd (), 'test.js').replace (/\\/g, '/'),
            line: 32,
            column: 47,
            calleeShort: 'shouldBeVisibleInStackTrace',
            fileName: 'test.js',
            fileRelative: 'test.js',
            fileShort: 'test.js',
            thirdParty: false,
            externalDomain: undefined
        })
    })

    it ('allows to read sources', () => {

        const stack = shouldBeVisibleInStackTrace ().withSources () // @hide

        stack.should.be.an.instanceof (StackTracey)
        stack.items[0].beforeParse.should.not.be.undefined // should preserve previous fields
        stack.items[0].sourceLine.should.equal ('    const shouldBeVisibleInStackTrace = () => new StackTracey () ')
        stack.items[0].hide.should.equal (true) // reads // @hide marker
        stack.items[1].hide.should.equal (true) // reads // @hide marker

        const cleanStack = stack.clean ()

        cleanStack.should.be.an.instanceof (StackTracey)

        StackTracey.locationsEqual (cleanStack.items[0], stack.items[0]).should.equal (true)  // should not clean top element
        StackTracey.locationsEqual (cleanStack.items[1], stack.items[1]).should.equal (false) // should clean second element (due to // @hide)
    })
    

    it ('allows to read sources (async)', () => {

        return shouldBeVisibleInStackTrace ().withSourcesAsync ().then (stack => { // @hide

            stack.should.be.an.instanceof (StackTracey)
            stack.items[0].beforeParse.should.not.be.undefined // should preserve previous fields
            stack.items[0].sourceLine.should.equal ('    const shouldBeVisibleInStackTrace = () => new StackTracey () ')
            stack.items[0].hide.should.equal (true) // reads // @hide marker
            stack.items[1].hide.should.equal (true) // reads // @hide marker

            return stack.cleanAsync ().then (cleanStack => {

                cleanStack.should.be.an.instanceof (StackTracey)

                StackTracey.locationsEqual (cleanStack.items[0], stack.items[0]).should.equal (true)  // should not clean top element
                StackTracey.locationsEqual (cleanStack.items[1], stack.items[1]).should.equal (false) // should clean second element (due to // @hide)
            })
        })
    })

    it ('allows creation from array + groups duplicate lines', () => {

        const stack = new StackTracey ([
            { file: 'yo.js',  line: 11, callee: 'a.funkktion',   calleeShort: 'a' },
            { file: 'yo.js',  line: 10, callee: 'foobar.boobar', calleeShort: 'foobar' },
            { file: 'yo.js',  line: 10, callee: 'foobar.boobar', calleeShort: 'foobar' },
            { file: 'lol.js', line: 10, callee: '',              calleeShort: '' },
        ])

        const clean = stack.clean ().map (x => Object.assign ({
                                                    file: x.file,
                                                    line: x.line,
                                                    callee: x.callee,
                                                    calleeShort: x.calleeShort }))

        clean.should.be.an.instanceof (StackTracey)

        clean.items.should.deep.equal ([ // .should does not recognize StackTracey as normal array...

            { file: 'yo.js',  line: 11, callee: 'a.funkktion',   calleeShort: 'a' },
            { file: 'yo.js',  line: 10, callee: 'foobar.boobar → foobar.boobar', calleeShort: 'foobar → foobar' },
            { file: 'lol.js', line: 10, callee: '',              calleeShort: '' },
        ])
    })

    it ('handles inaccessible files', () => {

        const stack = shouldBeVisibleInStackTrace ()
              stack.items[0].file = '^___^'
              stack.withSources ().items[0].sourceLine.should.equal ('')
              stack.withSourceAt (0).error.should.be.an.instanceof (Error)
    })

    it ('exposes some Array methods', () => {

        const stack = shouldBeVisibleInStackTrace ()
        const sliced = stack.slice (1)
        const deltaLength = (stack.items.length - sliced.items.length)

        deltaLength.should.equal (1)
        sliced.should.be.an.instanceof (StackTracey)

        sliced.filter (x => true).should.be.an.instanceof (StackTracey)
    })

    it ('works with sourcemaps', () => {

        const mkay = require ('./test_files/mkay.uglified')

        try {
            mkay ()
        }
        catch (e) {

            e.message.should.equal ('mkay')

            const top = new StackTracey (e).withSourceAt (0)

            top.line        .should.equal (4)
            top.sourceLine  .should.equal ('\t\t\t\t\tthrow new Error (\'mkay\') }')

            top.file        .should.equal (path.resolve ('./test_files/mkay.js').replace (/\\/g, '/'))
            top.fileShort   .should.equal ('test_files/mkay.js')
            top.fileName    .should.equal ('mkay.js')
        }
    })

    it ('pretty printing works', function prettyTest () {

        const pretty = new StackTracey ().clean ().asTable ()

        console.log ('')
        console.log (pretty, '\n')

        //const spaces = nodeVersion > 8 ? '        ' : '                      ';

        console.log (pretty.split ('\n')[0].match (/at prettyTest\s+test.js\:144\s+const pretty = new StackTracey \(\)\.clean\.pretty/))
    })

    it ('trims too long columns in the pretty printed output', () => {

        const stack = new StackTracey ([
            { fileShort: 'dasdasdasdadadadasdasdasdasdasddasdsadadasdassdasdaddadasdas.js', line: 11, calleeShort: 'dadasdasdasdasdasdasdasdasdasdasdasdasd' },
        ])

        stack.withSources ().asTable ().split ('\n')[0].should.equal ('at dadasdasdasdasdasdasdasdasdas…  …asdadadadasdasdasdasdasddasdsadadasdassdasdaddadasdas.js:11  ')
    })
    
    it ('exposes Array methods', () => {

        const stack = new StackTracey ([
            { file: 'foo' },
            { file: 'bar' }
        ])

        const mapped = stack.map ((x, i) => Object.assign (x, { i }))

        mapped.items.should.deep.equal ([ { file: 'foo', i: 0 }, { file: 'bar', i: 1 } ])
        mapped.should.be.an.instanceof (StackTracey)

        const filtered = stack.filter (x => x.file === 'bar')

        filtered.items.length.should.equal (1)
        filtered.items[0].should.deep.equal ({ file: 'bar', i: 1 })
    })

    it ('computes relative path correctly', () => {
        
        StackTracey.prototype.decomposePath ('webpack:///~/jquery/dist/jquery.js')
                             .should.deep.equal (      ['~/jquery/dist/jquery.js', undefined])

        StackTracey.prototype.decomposePath ('webpack:/webpack/bootstrap')
                             .should.deep.equal (    ['webpack/bootstrap', undefined])
    })

    it ('computes short path correctly', () => {

        StackTracey.prototype.shortenPath  ('webpack/bootstrap/jquery/dist/jquery.js')
                             .should.equal ('jquery/dist/jquery.js')

        StackTracey.prototype.shortenPath  ('node_modules/jquery/dist/jquery.js')
                             .should.equal ('jquery/dist/jquery.js')
    })

    if (nodeVersion >= 5) {

        it ('recognizes SyntaxErrors', () => {

            try { require ('./test_files/syntax_error.js') }
            catch (e) {

                const stack = new StackTracey (e).clean ()

                console.log ('')
                console.log (stack.asTable (), '\n')

                stack.items[0].syntaxError.should.equal (true)
                stack.items[0].column.should.equal (5)
                
                const spaces  = nodeVersion > 8 ? '    ' : '                  '
                const spaces2 = nodeVersion > 8 ? (nodeVersion > 11 ? '         ' : '        ') : '  '

                stack.asTable ().split ('\n')[0].should.equal ('at (syntax error)' + spaces + 'test_files/syntax_error.js:2' + spaces2 + 'foo->bar ()                                     ')
            }
        })
    }

    it ('allows to override isThirdParty()', () => {

        class MyStackTracey extends StackTracey {
            isThirdParty (path) {
                return super.isThirdParty (path) || (path === 'test.js')
            }
        }

        new MyStackTracey ().items[0].thirdParty.should.equal (true)

        class MyStackTracey2 extends MyStackTracey {
            isThirdParty (path) {
                return super.isThirdParty (path) && (path !== 'test.js')
            }
        }
        
        new MyStackTracey2 ().items[0].thirdParty.should.equal (false)
    })

    it ('.withSourceAt', () => {

        const line = new StackTracey ().withSourceAt (0).sourceLine.trim ()
        line.should.equal ('const line = new StackTracey ().withSourceAt (0).sourceLine.trim ()')
    })

    it ('.at', () => {
        
        new StackTracey ().at (0).file.includes ('stacktracey/test.js').should.equal (true)
    })

    it ('detects Array methods as native', () => {

        const arr = [1,2,3]
        const stack = arr.reduce (() => new StackTracey ())

        stack.items[1].native.should.equal (true)
    })

    it ('works on Windows', () => {

        const dir = process.cwd ()

        const windowsStack =
                [
                'Error',
                '    at Context.it (' + dir + '\\test.js:38:22)',
                '    at callFn (' + dir + '\\node_modules\\mocha\\lib\\runnable.js:354:21)',
                '    at runCallback (timers.js:800:20)'
                ].join ('\n')

        const stack = new StackTracey (windowsStack)
        const pretty = stack.withSources ().asTable ()
        const lines = pretty.split ('\n')

        console.log ('')
        console.log (pretty, '\n')

        lines[0].should.equal ('at it           test.js:38                 stack.should.be.an.instanceof (StackTracey)')
        lines[1].indexOf      ('at callFn       mocha/lib/runnable.js:354').should.equal (0)
    })

    it ('parses "eval at" stuff', () => {

        function bar() {
            const entry = new StackTracey().items[1]
            entry.callee.should.equal('eval')
            entry.fileName.should.equal('test.js')
        }
        function foo() {
            eval('bar()')
        }
        foo()
    })

    it ('recognizes externalDomain', () => {

        const stack =
        [
        'Error',
        '    at foo (test.js:38:22)',
        '    at bar (http://shmoogle.google.com/hohoho/test.js:38:22)',
        ].join ('\n')

        const items = new StackTracey(stack).items

        ;(items[0].externalDomain === undefined).should.be.true
        items[1].externalDomain.should.equal('shmoogle.google.com')

        items[0].thirdParty.should.be.false
        items[1].thirdParty.should.be.true

        items[1].fileRelative.should.equal('hohoho/test.js')
    })

    it ('recognizes locations without column', () => {
        const stack = [
        'Error',
        '    at ValidateCompatibilityWithBindGroupLayout (../../third_party/dawn/src/dawn_native/ShaderModule.cpp:395)',
        ].join ('\n')

        const items = new StackTracey(stack).items

        items[0].should.contain({
            callee: 'ValidateCompatibilityWithBindGroupLayout',
            calleeShort: 'ValidateCompatibilityWithBindGroupLayout',
            fileRelative: '../../third_party/dawn/src/dawn_native/ShaderModule.cpp',
            fileShort: '../../third_party/dawn/src/dawn_native/ShaderModule.cpp',
            fileName: 'ShaderModule.cpp'
        })
    })
})



