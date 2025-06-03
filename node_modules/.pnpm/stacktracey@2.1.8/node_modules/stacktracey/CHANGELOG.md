# Version 2.0 (with breaking changes)

- Added asynchronous methods, `withSourcesAsync` and `cleanAsync`.

- All property accessors like `.clean` are now methods (e.g. `.clean ()`) for consistency reasons

- `.pretty` now `.asTable (opts?: { maxColumnWidths:? { callee, file, sourceLine } })`

    - Also, it does not call `withSources` automatically — you need to call it explicitly.

- It is no longer `extends Array` due to non-working user subclassing with Babel ES5
    - Use `.items` to access original array

- No static methods and properties (except public `.locationsEqual` helper)
    - `.isThirdParty` is now just an overrideable method
    - `.maxColumnWidths` is an overrideable method + a configuration option passed to `asTable ()` method
