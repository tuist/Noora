
/*  TODO: make it work in Travis CI
    ------------------------------------------------------------------------ */

const selenium = require ('selenium-webdriver/testing')

/*  ------------------------------------------------------------------------ */

selenium.describe ('Chrome test', (done) => {

    const webdriver = require ('selenium-webdriver')
        , path      = require ('path')
        , fs        = require ('fs')
        , memFS     = new (require ('memory-fs')) ()
        , it        = selenium.it
        , webpack   = require ('webpack')
        , logging   = require ('selenium-webdriver/lib/logging')

    let driver

/*  Prepare ChromeDriver (with CORS disabled and log interception enabled)   */

    selenium.before (() => driver =
                            new webdriver
                                    .Builder ()
                                    .withCapabilities (
                                        webdriver.Capabilities
                                                .chrome ()
                                                .setLoggingPrefs (new logging.Preferences ().setLevel (logging.Type.BROWSER, logging.Level.ALL))
                                                .set ('chromeOptions', {
                                                        'args': ['--disable-web-security'] }))
                                    .build ())

    selenium.after  (() => driver.quit ())

    it ('works', async () => {

    /*  Compile get-source   */

        const compiledScript = await (new Promise (resolve => { Object.assign (webpack ({ 

                entry: './test/files/get-source.webpack.entry.js',
                output: { path: '/', filename: 'get-source.webpack.compiled.js' },
                plugins: [ new webpack.IgnorePlugin(/^fs$/) ]

            }), { outputFileSystem: memFS }).run ((err, stats) => {

                if (err) throw err

                resolve (memFS.readFileSync ('/get-source.webpack.compiled.js').toString ('utf-8'))
            })
        }))

    /*  Inject it into Chrome   */

        driver.get ('file://' + path.resolve ('./test/files/test.html'))
        driver.executeScript (compiledScript)

    /*  Execute test    */

        const exec = fn => driver.executeScript (`(${fn.toString ()})()`)

        try {

            await exec (function () {

                path.relativeToFile ('http://foo.com/scripts/bar.js', '../bar.js.map')
                    .should.equal ('http://foo.com/bar.js.map')

                path.relativeToFile ('http://foo.com/scripts/bar.js', 'http://bar.js.map')
                    .should.equal ('http://bar.js.map')

                path.relativeToFile ('http://foo.com/scripts/bar.js', '/bar.js.map')
                    .should.equal ('file:///bar.js.map')

                path.relativeToFile ('http://foo.com/scripts/bar.js', '//bar.com/bar.js.map')
                    .should.equal ('http://bar.com/bar.js.map')

                var loc = getSource ('../original.uglified.beautified.js').resolve ({ line: 2, column: 4 })

                loc.line.should.equal (4)
                loc.column.should.equal (2)
                loc.sourceFile.path.should.contain ('test/files/original.js')
                loc.sourceLine.should.equal ('\treturn \'hello world\' }')
            })

        } catch (e) { throw e } finally {

            driver.manage ().logs ().get (logging.Type.BROWSER).then (entries => {
                entries.forEach (entry => {
                    console.log('[BROWSER] [%s] %s', entry.level.name, entry.message);
                })
            })
        }
    })
})

/*  ------------------------------------------------------------------------ */
