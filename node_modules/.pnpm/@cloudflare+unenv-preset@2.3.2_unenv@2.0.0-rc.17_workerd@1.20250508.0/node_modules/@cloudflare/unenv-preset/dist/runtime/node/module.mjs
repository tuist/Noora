import { notImplemented } from "unenv/_internal/utils";
import {
  _cache,
  _debug,
  _extensions,
  _findPath,
  _initPaths,
  _load,
  _nodeModulePaths,
  _pathCache,
  _preloadModules,
  _resolveFilename,
  _resolveLookupPaths,
  builtinModules,
  constants,
  enableCompileCache,
  findSourceMap,
  getCompileCacheDir,
  globalPaths,
  isBuiltin,
  Module,
  register,
  runMain,
  SourceMap,
  syncBuiltinESMExports,
  wrap
} from "unenv/node/module";
export {
  Module,
  SourceMap,
  _cache,
  _extensions,
  _debug,
  _pathCache,
  _findPath,
  _initPaths,
  _load,
  _nodeModulePaths,
  _preloadModules,
  _resolveFilename,
  _resolveLookupPaths,
  builtinModules,
  constants,
  enableCompileCache,
  findSourceMap,
  getCompileCacheDir,
  globalPaths,
  isBuiltin,
  register,
  runMain,
  syncBuiltinESMExports,
  wrap
} from "unenv/node/module";
const workerdModule = process.getBuiltinModule("node:module");
export const createRequire = (file) => {
  return Object.assign(workerdModule.createRequire(file), {
    resolve: Object.assign(
      /* @__PURE__ */ notImplemented("module.require.resolve"),
      {
        paths: /* @__PURE__ */ notImplemented("module.require.resolve.paths")
      }
    ),
    cache: /* @__PURE__ */ Object.create(null),
    extensions: _extensions,
    main: void 0
  });
};
export default {
  Module,
  SourceMap,
  _cache,
  _extensions,
  _debug,
  _pathCache,
  _findPath,
  _initPaths,
  _load,
  _nodeModulePaths,
  _preloadModules,
  _resolveFilename,
  _resolveLookupPaths,
  builtinModules,
  enableCompileCache,
  constants,
  createRequire,
  findSourceMap,
  getCompileCacheDir,
  globalPaths,
  isBuiltin,
  register,
  runMain,
  syncBuiltinESMExports,
  wrap
};
