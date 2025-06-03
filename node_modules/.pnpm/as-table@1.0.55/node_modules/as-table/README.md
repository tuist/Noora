# as-table

[![Build Status](https://travis-ci.org/xpl/as-table.svg?branch=master)](https://travis-ci.org/xpl/as-table) [![Coverage Status](https://coveralls.io/repos/github/xpl/as-table/badge.svg)](https://coveralls.io/github/xpl/as-table) [![npm](https://img.shields.io/npm/v/as-table.svg)](https://npmjs.com/package/as-table) [![dependencies Status](https://david-dm.org/xpl/as-table/status.svg)](https://david-dm.org/xpl/as-table) [![Scrutinizer Code Quality](https://img.shields.io/scrutinizer/g/xpl/as-table.svg)](https://scrutinizer-ci.com/g/xpl/as-table/?branch=master)

A simple function that print objects and arrays as ASCII tables. Supports ANSI styling and weird 💩 Unicode emoji symbols (they won't break the layout), thanks to [`printable-characters`](https://github.com/xpl/printable-characters).

```bash
npm install as-table
```

## Printing objects

```javascript
asTable = require ('as-table')

asTable ([ { foo: true,  string: 'abcde',      num: 42 },
           { foo: false, string: 'qwertyuiop', num: 43 },
           {             string:  null,        num: 44 } ])
```
```
foo    string      num
----------------------
true   abcde       42 
false  qwertyuiop  43 
       null        44 
```

## Printing arrays

```javascript
asTable ([['qwe',       '123456789', 'zxcvbnm'],
          ['qwerty',    '12',        'zxcvb'],
          ['qwertyiop', '1234567',   'z']])
```
```
qwe        123456789  zxcvbnm
qwerty     12         zxcvb
qwertyiop  1234567    z
```

## Limiting total width by proportionally trimming cells + setting columns delimiter

```javascript
asTable.configure ({ maxTotalWidth: 22, delimiter: ' | ' }) (data)
```
```
qwe   | 1234… | zxc…
qwer… | 12    | zxc…
qwer… | 1234… | z   
```

## Right align

```javascript
asTable.configure ({ right: true }) (data)
```
```
      foo        bar      baz
-----------------------------
      qwe  123456789  zxcvbnm
   qwerty         12    zxcvb
qwertyiop    1234567        z
```

## Providing a custom object printer

```javascript
asTable.configure ({ print: x => (typeof x === 'boolean') ? (x ? 'yes' : 'no') : String (x) }) (data)
```
```
foo  string      num
--------------------
yes  abcde       42 
no   qwertyuiop  43 
     null        44 
```

The callback also receives a field name (in case of objects) or a column index (in case of arrays):

```javascript
asTable = require ('as-table').configure ({
    print (x, k) {
        if (k === 'timestamp') return new Date (x).toGMTString()
        return String (x)
    }
})

asTable ([ { name: 'A', timestamp: 1561202591572 },
           { name: 'B', timestamp: 1558524240034 } ])
```

## Obtaining a pre-configured function

```javascript
asTable = require ('as-table').configure ({ maxTotalWidth: 25, delimiter: ' | ' })

asTable (data)
```

## Customizing the title rendering and the header separator

With string coloring by [`ansicolor`](https://github.com/xpl/ansicolor) (just for the demo purposes, any library will fit):

```javascript
asTable = require ('as-table').configure ({ title: x => x.bright, delimiter: ' | '.dim.cyan, dash: '-'.bright.cyan })

console.log (
   asTable ([ { foo: true,  string: 'abcde',                             num: 42 },
              { foo: false, string: 'qwertyuiop'.bgMagenta.green.bright, num: 43 } ])
```

<img width="179" alt="screen shot 2017-07-21 at 23 46 14" src="https://user-images.githubusercontent.com/1707/28481945-dcb0f8d6-6e6e-11e7-896e-dfad40662daf.png">

