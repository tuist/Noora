import { Timeout } from "./timeout.mjs";
export function setTimeoutFallbackPromises(delay, value, options) {
	return new Promise((res) => {
		res(value);
	});
}
export function setTimeoutFallback(callback, ms, ...args) {
	return new Timeout(callback, args);
}
setTimeoutFallback.__promisify__ = setTimeoutFallbackPromises;
