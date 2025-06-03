# printable-characters

[![Build Status](https://travis-ci.org/xpl/printable-characters.svg?branch=master)](https://travis-ci.org/xpl/printable-characters) [![Coverage Status](https://coveralls.io/repos/github/xpl/printable-characters/badge.svg)](https://coveralls.io/github/xpl/printable-characters) [![npm](https://img.shields.io/npm/v/printable-characters.svg)](https://npmjs.com/package/printable-characters) [![Scrutinizer Code Quality](https://img.shields.io/scrutinizer/g/xpl/printable-characters.svg)](https://scrutinizer-ci.com/g/xpl/printable-characters/?branch=master) [![dependencies Status](https://david-dm.org/xpl/printable-characters/status.svg)](https://david-dm.org/xpl/printable-characters)

A little helper for handling strings containing zero width characters, ANSI styling, whitespaces, newlines, [weird Unicode 💩 symbols](http://blog.jonnew.com/posts/poo-dot-length-equals-two), etc.

## Determining the real (visible) length of a string

```javascript
const { strlen } = require ('printable-characters')

strlen ('foo bar') // === 7
strlen ('\u001b[106mfoo bar\u001b[49m') // === 7
```

## Detecting blank text

```javascript
const { isBlank } = require ('printable-characters')

isBlank ('foobar') // === false
isBlank ('\u001b[106m  \t  \t   \n     \u001b[49m') // === true
```

## Obtaining a blank string of the same width

```javascript
const { blank } = require ('printable-characters')

blank ('💩')          // === ' '
blank ('foo')         // === '   '
blank ('\tfoo \nfoo') // === '\t    \n   '
blank ('\u001b[22m\u001b[1mfoo \t\u001b[39m\u001b[22m')) // === '    \t'
```

## Matching invisible characters

```javascript
const { ansiEscapeCodes, zeroWidthCharacters } = require ('printable-characters')

const s = '\u001b[106m' + 'foo' + '\n' + 'bar' + '\u001b[49m'

s.replace (ansiEscapeCodes, '')     // === 'foo\nbar'
 .replace (zeroWidthCharacters, '') // === 'foobar'
```

## Getting the first N visible symbols, preserving the invisible parts

Use for safely truncating strings to maximum width without breaking ANSI codes:

```javascript
const { first } = require ('printable-characters')

const s = '\u001b[22mfoobar\u001b[22m'

first (s, 0) // === '\u001b[22m\u001b[22m'
first (s, 1) // === '\u001b[22mf\u001b[22m'
first (s, 3) // === '\u001b[22mfoo\u001b[22m'
first (s, 6) // === '\u001b[22mfoobar\u001b[22m'
```

## Extracting the invisible parts followed by the visible ones (parsing)

```javascript
const { partition } = require ('printable-characters')

partition ('')                        // [                                                     ])
partition ('foo')                     // [['',          'foo']                                 ])
partition ('\u001b[1mfoo')            // [['\u001b[1m', 'foo']                                 ])
partition ('\u001b[1mfoo\u0000bar')   // [['\u001b[1m', 'foo'],   ['\u0000', 'bar']            ])
partition ('\u001b[1mfoo\u0000bar\n') // [['\u001b[1m', 'foo'],   ['\u0000', 'bar'], ['\n', '']])
```

## Applications

- [as-table](https://github.com/xpl/as-table) — a simple function that prints objects as ASCII tables
- [string.bullet](https://github.com/xpl/string.bullet) — ASCII-mode bulleting for the list-style data
- [string.ify](https://github.com/xpl/string.ify) — a fancy pretty printer for the JavaScript entities
- [Ololog!](https://github.com/xpl/ololog) — a better `console.log` for the log-driven debugging junkies!

## TODO

Handle multi-component emojis, as in [this article](http://blog.jonnew.com/posts/poo-dot-length-equals-two):

```javascript
assert.equal (strlen ('👩‍❤️‍💋‍👩'), 1)  // FAILING, see http://blog.jonnew.com/posts/poo-dot-length-equals-two for possible solution
assert.equal (blank ('👩‍❤️‍💋‍👩'), ' ') // FAILING, see http://blog.jonnew.com/posts/poo-dot-length-equals-two for possible solution
```
