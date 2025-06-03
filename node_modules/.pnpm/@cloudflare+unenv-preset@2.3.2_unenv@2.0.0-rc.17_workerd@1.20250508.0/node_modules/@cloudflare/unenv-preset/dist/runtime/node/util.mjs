import {
  _errnoException,
  _exceptionWithHostPort,
  getSystemErrorMap,
  getSystemErrorName,
  isBoolean,
  isBuffer,
  isDate,
  isError,
  isFunction,
  isNull,
  isNullOrUndefined,
  isNumber,
  isObject,
  isPrimitive,
  isRegExp,
  isString,
  isSymbol,
  isUndefined,
  parseEnv,
  styleText
} from "unenv/node/util";
export {
  _errnoException,
  _exceptionWithHostPort,
  getSystemErrorMap,
  getSystemErrorName,
  isBoolean,
  isBuffer,
  isDate,
  isError,
  isFunction,
  isNull,
  isNullOrUndefined,
  isNumber,
  isObject,
  isPrimitive,
  isRegExp,
  isString,
  isSymbol,
  isUndefined,
  parseEnv,
  styleText
} from "unenv/node/util";
const workerdUtil = process.getBuiltinModule("node:util");
export const {
  MIMEParams,
  MIMEType,
  TextDecoder,
  TextEncoder,
  // @ts-expect-error missing types?
  _extend,
  aborted,
  callbackify,
  debug,
  debuglog,
  deprecate,
  format,
  formatWithOptions,
  // @ts-expect-error unknown type
  getCallSite,
  inherits,
  inspect,
  isArray,
  isDeepStrictEqual,
  log,
  parseArgs,
  promisify,
  stripVTControlCharacters,
  toUSVString,
  transferableAbortController,
  transferableAbortSignal
} = workerdUtil;
export const types = workerdUtil.types;
export default {
  /**
   * manually unroll unenv-polyfilled-symbols to make it tree-shakeable
   */
  _errnoException,
  _exceptionWithHostPort,
  // @ts-expect-error unenv has unknown type
  getSystemErrorMap,
  // @ts-expect-error unenv has unknown type
  getSystemErrorName,
  isBoolean,
  isBuffer,
  isDate,
  isError,
  isFunction,
  isNull,
  isNullOrUndefined,
  isNumber,
  isObject,
  isPrimitive,
  isRegExp,
  isString,
  isSymbol,
  isUndefined,
  // @ts-expect-error unenv has unknown type
  parseEnv,
  // @ts-expect-error unenv has unknown type
  styleText,
  /**
   * manually unroll workerd-polyfilled-symbols to make it tree-shakeable
   */
  _extend,
  aborted,
  callbackify,
  debug,
  debuglog,
  deprecate,
  format,
  formatWithOptions,
  getCallSite,
  inherits,
  inspect,
  isArray,
  isDeepStrictEqual,
  log,
  MIMEParams,
  MIMEType,
  parseArgs,
  promisify,
  stripVTControlCharacters,
  TextDecoder,
  TextEncoder,
  toUSVString,
  transferableAbortController,
  transferableAbortSignal,
  // special-cased deep merged symbols
  types
};
