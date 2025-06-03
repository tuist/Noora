# get-source

[![Build Status](https://travis-ci.org/xpl/get-source.svg?branch=master)](https://travis-ci.org/xpl/get-source) [![Coverage Status](https://coveralls.io/repos/github/xpl/get-source/badge.svg)](https://coveralls.io/github/xpl/get-source) [![npm](https://img.shields.io/npm/v/get-source.svg)](https://npmjs.com/package/get-source)

Fetch source-mapped sources. Peek by file, line, column. Node & browsers. Sync & async.

```bash
npm install get-source
```

## Features

- [x] Allows to read source code files in Node and browsers
- [x] Full sourcemap support (path resolving, external/embedded/inline linking, and long chains)
- [x] **Synchronous** API — good for CLI tools (e.g. [logging](https://github.com/xpl/ololog)). Works in browsers!
- [x] **Asynchronous** API — good for everything web!
- [x] Built-in cache

## What for

- [x] Call stacks enhanced with source code information (see the [StackTracey](https://github.com/xpl/stacktracey) library)
- [x] [Advanced logging](https://github.com/xpl/ololog) / assertion printing
- [x] [Error displaying components](https://github.com/xpl/panic-overlay) for front-end web development

## Usage (Synchronous)

```javascript
import getSource from 'get-source'
```
```javascript
file = getSource ('./scripts/index.min.js')
```

Will read the file synchronously (either via XHR or by filesystem API, depending on the environment) and return it's cached representation. Result will contain the following fields:

```javascript
file.path  // normalized file path
file.text  // text contents
file.lines // array of lines
```

And the `resolve` method:

```javascript
file.resolve ({ line: 1, column: 8 }) // indexes here start from 1 (by widely accepted convention). Zero indexes are invalid.
```

It will look through the sourcemap chain, returning following:

```javascript
{
   line:       <original line number>,
   column:     <original column number>,
   sourceFile: <original source file object>,
   sourceLine: <original source line text>
}
```

In that returned object, `sourceFile` is the same kind of object that `getSource` returns. So you can access its `text`, `lines` and `path` fields to obtain the full information. And the `sourceLine` is returned just for the convenience, as a shortcut.

## Usage (Asynchronous)

Pretty much the same as synchronous, except it's `getSource.async`. It returns awaitable promises:

```javascript
file     = await getSource.async ('./scripts/index.min.js')
location = await file.resolve ({ line: 1, column: 8 })
```

## Error handling

In synchronous mode, it never throws (due to backward compatibility reasons with existing code):

```javascript
nonsense = getSource ('/some/nonexistent/file')

nonsense.text  // should be '' (so it's safe to access without checking)
nonsense.error // should be an Error object, representing an actual error thrown during reading/parsing
```
```javascript
resolved = nonsense.resolve ({ line: 5, column: 0 })

resolved.sourceLine // empty string (so it's safe to access without checking)
resolved.error      // should be an Error object, representing an actual error thrown during reading/parsing
```

In asychronous mode, it throws an error:

```javascript
try { 
   file     = await getSource.async ('/some/file')
   location = await file.resolve ({ line: 5, column: 0 })
} catch (e) {
   ...
}
```

## Resetting Cache

E.g. when you need to force-reload files:

```javascript
getSource.resetCache ()        // sync cache
getSource.async.resetCache ()  // async cache
```

Also, viewing cached files:

```javascript
getSource.getCache ()        // sync cache
getSource.async.getCache ()  // async cache
```
