import { isEqual as _ohashIsEqual } from "ohash/utils";
import { notImplemented, notImplementedClass } from "../_internal/utils.mjs";
const ERR_AMBIGUOUS_ARGUMENT = Error;
const ERR_INVALID_ARG_TYPE = Error;
const ERR_INVALID_ARG_VALUE = Error;
const ERR_INVALID_RETURN_VALUE = Error;
const ERR_MISSING_ARGS = Error;
export class AssertionError extends Error {
	actual;
	expected;
	operator;
	generatedMessage;
	code = "ERR_ASSERTION";
	constructor(options) {
		super();
		this.actual = options.actual;
		this.expected = options.expected;
		this.operator = options.operator || "";
		this.generatedMessage = options.message === undefined;
		const stackStartFn = options.stackStartFn || fail;
		Error.captureStackTrace?.(this, stackStartFn);
	}
}
const inspect = (val, opts) => val;
const isDeepEqual = _ohashIsEqual;
const isDeepStrictEqual = _ohashIsEqual;
let warned = false;
const NO_EXCEPTION_SENTINEL = {};
/**
* Pure assertion tests whether a value is truthy, as determined
* by !!value.
* @param {...any} args
* @returns {void}
*/
export function ok(...args) {
	innerOk(ok, args.length, ...args);
}
/**
* The equality assertion tests shallow, coercive equality with ==.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function equal(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (actual != expected && (!Number.isNaN(actual) || !Number.isNaN(expected))) {
		innerFail({
			actual,
			expected,
			message,
			operator: "==",
			stackStartFn: equal
		});
	}
}
/**
* The non-equality assertion tests for whether two objects are not
* equal with !=.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function notEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (actual == expected || Number.isNaN(actual) && Number.isNaN(expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "!=",
			stackStartFn: notEqual
		});
	}
}
/**
* The deep equivalence assertion tests a deep equality relation.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function deepEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (!isDeepEqual(actual, expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "deepEqual",
			stackStartFn: deepEqual
		});
	}
}
/**
* The deep non-equivalence assertion tests for any deep inequality.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function notDeepEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (isDeepEqual(actual, expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "notDeepEqual",
			stackStartFn: notDeepEqual
		});
	}
}
/**
* The deep strict equivalence assertion tests a deep strict equality
* relation.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function deepStrictEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (!isDeepStrictEqual(actual, expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "deepStrictEqual",
			stackStartFn: deepStrictEqual
		});
	}
}
/**
* The deep strict non-equivalence assertion tests for any deep strict
* inequality.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function notDeepStrictEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (isDeepStrictEqual(actual, expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "notDeepStrictEqual",
			stackStartFn: notDeepStrictEqual
		});
	}
}
/**
* The strict equivalence assertion tests a strict equality relation.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function strictEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (!Object.is(actual, expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "strictEqual",
			stackStartFn: strictEqual
		});
	}
}
/**
* The strict non-equivalence assertion tests for any strict inequality.
* @param {any} actual
* @param {any} expected
* @param {string | Error} [message]
* @returns {void}
*/
export function notStrictEqual(actual, expected, message) {
	if (arguments.length < 2) {
		throw new ERR_MISSING_ARGS("actual", "expected");
	}
	if (Object.is(actual, expected)) {
		innerFail({
			actual,
			expected,
			message,
			operator: "notStrictEqual",
			stackStartFn: notStrictEqual
		});
	}
}
/**
* Expects the function `promiseFn` to throw an error.
*/
export function throws(promiseFn, ...args) {
	expectsError(throws, getActual(promiseFn), ...args);
}
/**
* Expects `promiseFn` function or its value to reject.
*/
export async function rejects(promiseFn, ...args) {
	expectsError(rejects, await waitForActual(promiseFn), ...args);
}
/**
* Asserts that the function `fn` does not throw an error.
*/
export function doesNotThrow(fn, ...args) {
	expectsNoError(doesNotThrow, getActual(fn), ...args);
}
/**
* Expects `fn` or its value to not reject.
*/
export async function doesNotReject(fn, ...args) {
	expectsNoError(doesNotReject, await waitForActual(fn), ...args);
}
/**
* Throws `value` if the value is not `null` or `undefined`.
* @param {any} err
* @returns {void}
*/
export function ifError(err) {
	if (err !== null && err !== undefined) {
		let message = "ifError got unwanted exception: ";
		if (typeof err === "object" && typeof err.message === "string") {
			if (err.message.length === 0 && err.constructor) {
				message += err.constructor.name;
			} else {
				message += err.message;
			}
		} else {
			message += inspect(err);
		}
		const newErr = new AssertionError({
			actual: err,
			expected: null,
			operator: "ifError",
			message,
			stackStartFn: ifError
		});
		const origStack = err?.stack;
		if (typeof origStack === "string") {
			const origStackStart = origStack.indexOf("\n    at");
			if (origStackStart !== -1) {
				const originalFrames = origStack.slice(origStackStart + 1).split("\n");
				let newFrames = (newErr.stack || "").split("\n");
				for (const errFrame of originalFrames) {
					const pos = newFrames.indexOf(errFrame);
					if (pos !== -1) {
						newFrames = newFrames.slice(0, pos);
						break;
					}
				}
				const stackStart = newFrames.join("\n");
				const stackEnd = originalFrames.join("\n");
				newErr.stack = `${stackStart}\n${stackEnd}`;
			}
		}
		throw newErr;
	}
}
/**
* Expects the `string` input to match the regular expression.
* @param {string} string
* @param {RegExp} regexp
* @param {string | Error} [message]
* @returns {void}
*/
export function match(string, regexp, message) {
	internalMatch(string, regexp, message, match);
}
/**
* Expects the `string` input not to match the regular expression.
* @param {string} string
* @param {RegExp} regexp
* @param {string | Error} [message]
* @returns {void}
*/
export function doesNotMatch(string, regexp, message) {
	internalMatch(string, regexp, message, doesNotMatch);
}
export function fail(actual, expected, message, operator, stackStartFn) {
	const argsLen = arguments.length;
	let internalMessage = false;
	if (actual == null && argsLen <= 1) {
		internalMessage = true;
		message = "Failed";
	} else if (argsLen === 1) {
		message = actual;
		actual = undefined;
	} else {
		if (warned === false) {
			warned = true;
			process.emitWarning("assert.fail() with more than one argument is deprecated. " + "Please use assert.strictEqual() instead or only pass a message.", "DeprecationWarning", "DEP0094");
		}
		if (argsLen === 2) operator = "!=";
	}
	if (message instanceof Error) throw message;
	const errArgs = {
		actual,
		expected,
		operator: operator === undefined ? "fail" : operator,
		stackStartFn: stackStartFn || fail,
		message
	};
	const err = new AssertionError(errArgs);
	if (internalMessage) {
		err.generatedMessage = true;
	}
	throw err;
}
function innerFail(obj) {
	if (obj.message instanceof Error) throw obj.message;
	throw new AssertionError(obj);
}
function innerOk(fn, argLen, value, message) {
	if (!value) {
		let generatedMessage = false;
		if (argLen === 0) {
			generatedMessage = true;
			message = "No value argument passed to `assert.ok()`";
		} else if (message == null) {
			generatedMessage = true;
			message = "<null>";
		} else if (message instanceof Error) {
			throw message;
		}
		const err = new AssertionError({
			actual: value,
			expected: true,
			message,
			operator: "==",
			stackStartFn: fn
		});
		err.generatedMessage = generatedMessage;
		throw err;
	}
}
class Comparison {
	constructor(obj, keys, actual) {
		for (const key of keys) {
			if (key in obj) {
				if (actual !== undefined && typeof actual[key] === "string" && obj[key] instanceof RegExp && obj[key].exec(actual[key]) !== null) {
					this[key] = actual[key];
				} else {
					this[key] = obj[key];
				}
			}
		}
	}
}
function compareExceptionKey(actual, expected, key, message, keys, fn) {
	if (!(key in actual) || !isDeepStrictEqual(actual[key], expected[key])) {
		if (!message) {
			const a = new Comparison(actual, keys);
			const b = new Comparison(expected, keys, actual);
			const err = new AssertionError({
				actual: a,
				expected: b,
				operator: "deepStrictEqual",
				stackStartFn: fn
			});
			err.actual = actual;
			err.expected = expected;
			err.operator = fn.name;
			throw err;
		}
		innerFail({
			actual,
			expected,
			message,
			operator: fn.name,
			stackStartFn: fn
		});
	}
}
function expectedException(actual, expected, message, fn) {
	let generatedMessage = false;
	let throwError = false;
	if (typeof expected !== "function") {
		if (expected instanceof RegExp) {
			const str = String(actual);
			if (RegExp.prototype.exec.call(expected, str) !== null) return;
			if (!message) {
				generatedMessage = true;
				message = "The input did not match the regular expression " + `${inspect(expected)}. Input:\n\n${inspect(str)}\n`;
			}
			throwError = true;
		} else if (typeof actual !== "object" || actual === null) {
			const err = new AssertionError({
				actual,
				expected,
				message,
				operator: "deepStrictEqual",
				stackStartFn: fn
			});
			err.operator = fn.name;
			throw err;
		} else {
			const keys = Object.keys(expected);
			if (expected instanceof Error) {
				keys.push("name", "message");
			} else if (keys.length === 0) {
				throw new ERR_INVALID_ARG_VALUE(
					"error",
					expected,
					// @ts-expect-error
					"may not be an empty object"
);
			}
			for (const key of keys) {
				if (typeof actual[key] === "string" && expected[key] instanceof RegExp && expected[key].exec(actual[key]) !== null) {
					continue;
				}
				compareExceptionKey(actual, expected, key, message, keys, fn);
			}
			return;
		}
	} else if (expected.prototype !== undefined && actual instanceof expected) {
		return;
	} else if (expected instanceof Error) {
		if (!message) {
			generatedMessage = true;
			message = "The error is expected to be an instance of " + `"${expected.name}". Received `;
			if (actual instanceof Error) {
				const name = actual.constructor && actual.constructor.name || actual.name;
				if (expected.name === name) {
					message += "an error with identical name but a different prototype.";
				} else {
					message += `"${name}"`;
				}
				if (actual.message) {
					message += `\n\nError message:\n\n${actual.message}`;
				}
			} else {
				message += `"${inspect(actual, { depth: -1 })}"`;
			}
		}
		throwError = true;
	} else {
		const res = Reflect.apply(expected, {}, [actual]);
		if (res !== true) {
			if (!message) {
				generatedMessage = true;
				const name = expected.name ? `"${expected.name}" ` : "";
				message = `The ${name}validation function is expected to return` + ` "true". Received ${inspect(res)}`;
				if (actual instanceof Error) {
					message += `\n\nCaught error:\n\n${actual}`;
				}
			}
			throwError = true;
		}
	}
	if (throwError) {
		const err = new AssertionError({
			actual,
			expected,
			message,
			operator: fn.name,
			stackStartFn: fn
		});
		err.generatedMessage = generatedMessage;
		throw err;
	}
}
function getActual(fn) {
	try {
		fn();
	} catch (error_) {
		return error_;
	}
	return NO_EXCEPTION_SENTINEL;
}
function checkIsPromise(obj) {
	return obj instanceof Promise || obj !== null && typeof obj === "object" && typeof obj.then === "function" && typeof obj.catch === "function";
}
function internalMatch(string, regexp, message, fn) {
	if (!(regexp instanceof RegExp)) {
		throw new ERR_INVALID_ARG_TYPE("regexp", "RegExp", regexp);
	}
	const match = fn === assert.match;
	if (typeof string !== "string" || regexp.exec(string) !== null !== match) {
		if (message instanceof Error) {
			throw message;
		}
		const generatedMessage = !message;
		message = message || (typeof string === "string" ? (match ? "The input did not match the regular expression " : "The input was expected to not match the regular expression ") + `${inspect(regexp)}. Input:\n\n${inspect(string)}\n` : "The \"string\" argument must be of type string. Received type " + `${typeof string} (${inspect(string)})`);
		const err = new AssertionError({
			actual: string,
			expected: regexp,
			message,
			operator: fn?.name,
			stackStartFn: fn
		});
		err.generatedMessage = generatedMessage;
		throw err;
	}
}
async function waitForActual(promiseFn) {
	let resultPromise;
	if (typeof promiseFn === "function") {
		resultPromise = promiseFn();
		if (!checkIsPromise(resultPromise)) {
			throw new ERR_INVALID_RETURN_VALUE(
				"instance of Promise",
				"promiseFn",
				// @ts-expect-error
				resultPromise
);
		}
	} else if (checkIsPromise(promiseFn)) {
		resultPromise = promiseFn;
	} else {
		throw new ERR_INVALID_ARG_TYPE(
			"promiseFn",
			["Function", "Promise"],
			// @ts-expect-error
			promiseFn
);
	}
	try {
		await resultPromise;
	} catch (error_) {
		return error_;
	}
	return NO_EXCEPTION_SENTINEL;
}
function expectsError(stackStartFn, actual, error, message) {
	if (typeof error === "string") {
		if (arguments.length === 4) {
			throw new ERR_INVALID_ARG_TYPE(
				"error",
				[
					"Object",
					"Error",
					"Function",
					"RegExp"
				],
				// @ts-expect-error
				error
);
		}
		if (typeof actual === "object" && actual !== null) {
			if (actual?.message === error) {
				throw new ERR_AMBIGUOUS_ARGUMENT(
					"error/message",
					// @ts-expect-error
					`The error message "${actual.message}" is identical to the message.`
);
			}
		} else if (actual === error) {
			throw new ERR_AMBIGUOUS_ARGUMENT(
				"error/message",
				// @ts-expect-error
				`The error "${actual}" is identical to the message.`
);
		}
		message = error;
		error = undefined;
	} else if (error != null && typeof error !== "object" && typeof error !== "function") {
		throw new ERR_INVALID_ARG_TYPE(
			"error",
			[
				"Object",
				"Error",
				"Function",
				"RegExp"
			],
			// @ts-expect-error
			error
);
	}
	if (actual === NO_EXCEPTION_SENTINEL) {
		let details = "";
		if (error && error.name) {
			details += ` (${error.name})`;
		}
		details += message ? `: ${message}` : ".";
		const fnType = stackStartFn === assert.rejects ? "rejection" : "exception";
		innerFail({
			actual: undefined,
			expected: error,
			operator: stackStartFn.name,
			message: `Missing expected ${fnType}${details}`,
			stackStartFn
		});
	}
	if (!error) return;
	expectedException(actual, error, message, stackStartFn);
}
function hasMatchingError(actual, expected) {
	if (typeof expected !== "function") {
		if (expected instanceof RegExp) {
			const str = String(actual);
			return RegExp.prototype.exec.call(expected, str) !== null;
		}
		throw new ERR_INVALID_ARG_TYPE(
			"expected",
			["Function", "RegExp"],
			// @ts-expect-error
			expected
);
	}
	if (expected.prototype !== undefined && actual instanceof expected) {
		return true;
	}
	if (expected instanceof Error) {
		return false;
	}
	return Reflect.apply(expected, {}, [actual]) === true;
}
function expectsNoError(stackStartFn, actual, error, message) {
	if (actual === NO_EXCEPTION_SENTINEL) return;
	if (typeof error === "string") {
		message = error;
		error = undefined;
	}
	if (!error || hasMatchingError(actual, error)) {
		const details = message ? `: ${message}` : ".";
		const fnType = stackStartFn === assert.doesNotReject ? "rejection" : "exception";
		innerFail({
			actual,
			expected: error,
			operator: stackStartFn?.name,
			message: `Got unwanted ${fnType}${details}\n` + `Actual message: "${actual && actual.message}"`,
			stackStartFn
		});
	}
	throw actual;
}
const assert = Object.assign(ok, {});
export const CallTracker = /* @__PURE__ */ notImplementedClass("asset.CallTracker");
export const partialDeepStrictEqual = /* @__PURE__ */ notImplemented("assert.partialDeepStrictEqual");
assert.fail = fail;
assert.ok = ok;
assert.equal = equal;
assert.notEqual = notEqual;
assert.deepEqual = deepEqual;
assert.notDeepEqual = notDeepEqual;
assert.deepStrictEqual = deepStrictEqual;
assert.notDeepStrictEqual = notDeepStrictEqual;
assert.strictEqual = strictEqual;
assert.notStrictEqual = notStrictEqual;
assert.throws = throws;
assert.rejects = rejects;
assert.doesNotThrow = doesNotThrow;
assert.doesNotReject = doesNotReject;
assert.ifError = ifError;
assert.match = match;
assert.doesNotMatch = doesNotMatch;
assert.partialDeepStrictEqual = partialDeepStrictEqual;
assert.AssertionError = AssertionError;
assert.CallTracker = CallTracker;
export const strict = Object.assign(function _strict(...args) {
	innerOk(strict, args.length, ...args);
}, assert, {
	equal: assert.strictEqual,
	deepEqual: assert.deepStrictEqual,
	notEqual: assert.notStrictEqual,
	notDeepEqual: assert.notDeepStrictEqual
});
assert.strict = strict;
assert.strict.strict = assert.strict;
export default assert;
