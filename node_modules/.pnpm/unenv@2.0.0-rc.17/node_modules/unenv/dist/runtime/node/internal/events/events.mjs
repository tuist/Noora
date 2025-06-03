import { AsyncResource } from "node:async_hooks";
let defaultMaxListeners = 10;
const AsyncIteratorPrototype = Object.getPrototypeOf(Object.getPrototypeOf(async function* () {}).prototype);
const inspect = (value, _opts) => value;
const ERR_INVALID_THIS = Error;
const ERR_UNHANDLED_ERROR = Error;
const ERR_INVALID_ARG_TYPE = Error;
const AbortError = Error;
const genericNodeError = Error;
const kRejection = /* @__PURE__ */ Symbol.for("nodejs.rejection");
const kCapture = /* @__PURE__ */ Symbol.for("kCapture");
const kErrorMonitor = /* @__PURE__ */ Symbol.for("events.errorMonitor");
const kShapeMode = /* @__PURE__ */ Symbol.for("shapeMode");
const kMaxEventTargetListeners = /* @__PURE__ */ Symbol.for("events.maxEventTargetListeners");
const kEnhanceStackBeforeInspector = /* @__PURE__ */ Symbol.for("kEnhanceStackBeforeInspector");
const kWatermarkData = /* @__PURE__ */ Symbol.for("nodejs.watermarkData");
const kEventEmitter = /* @__PURE__ */ Symbol.for("kEventEmitter");
const kAsyncResource = /* @__PURE__ */ Symbol.for("kAsyncResource");
const kFirstEventParam = /* @__PURE__ */ Symbol.for("kFirstEventParam");
const kResistStopPropagation = /* @__PURE__ */ Symbol.for("kResistStopPropagation");
const kMaxEventTargetListenersWarned = /* @__PURE__ */ Symbol.for("events.maxEventTargetListenersWarned");
export class _EventEmitter {
	_events = undefined;
	_eventsCount = 0;
	_maxListeners = defaultMaxListeners;
	[kCapture] = false;
	[kShapeMode] = false;
	static captureRejectionSymbol = kRejection;
	static errorMonitor = kErrorMonitor;
	static kMaxEventTargetListeners = kMaxEventTargetListeners;
	static kMaxEventTargetListenersWarned = kMaxEventTargetListenersWarned;
	static usingDomains = false;
	static get on() {
		return on;
	}
	static get once() {
		return once;
	}
	static get getEventListeners() {
		return getEventListeners;
	}
	static get getMaxListeners() {
		return getMaxListeners;
	}
	static get addAbortListener() {
		return addAbortListener;
	}
	static get EventEmitterAsyncResource() {
		return EventEmitterAsyncResource;
	}
	static get EventEmitter() {
		return _EventEmitter;
	}
	static setMaxListeners(n = defaultMaxListeners, ...eventTargets) {
		if (eventTargets.length === 0) {
			defaultMaxListeners = n;
		} else {
			for (const target of eventTargets) {
				if (isEventTarget(target)) {
					target[kMaxEventTargetListeners] = n;
					target[kMaxEventTargetListenersWarned] = false;
				} else if (typeof target.setMaxListeners === "function") {
					target.setMaxListeners(n);
				} else {
					throw new ERR_INVALID_ARG_TYPE(
						"eventTargets",
						["EventEmitter", "EventTarget"],
						// @ts-expect-error
						target
);
				}
			}
		}
	}
	static listenerCount(emitter, type) {
		if (typeof emitter.listenerCount === "function") {
			return emitter.listenerCount(type);
		}
		_EventEmitter.prototype.listenerCount.call(emitter, type);
	}
	static init() {
		throw new Error("EventEmitter.init() is not implemented.");
	}
	static get captureRejections() {
		return this[kCapture];
	}
	static set captureRejections(value) {
		this[kCapture] = value;
	}
	static get defaultMaxListeners() {
		return defaultMaxListeners;
	}
	static set defaultMaxListeners(arg) {
		defaultMaxListeners = arg;
	}
	constructor(opts) {
		if (this._events === undefined || this._events === Object.getPrototypeOf(this)._events) {
			this._events = { __proto__: null };
			this._eventsCount = 0;
			this[kShapeMode] = false;
		} else {
			this[kShapeMode] = true;
		}
		this._maxListeners = this._maxListeners || undefined;
		if (opts?.captureRejections) {
			this[kCapture] = Boolean(opts.captureRejections);
		} else {
			this[kCapture] = _EventEmitter.prototype[kCapture];
		}
	}
	/**
	* Increases the max listeners of the event emitter.
	* @param {number} n
	* @returns {EventEmitter}
	*/
	setMaxListeners(n) {
		this._maxListeners = n;
		return this;
	}
	/**
	* Returns the current max listener value for the event emitter.
	* @returns {number}
	*/
	getMaxListeners() {
		return _getMaxListeners(this);
	}
	/**
	* Synchronously calls each of the listeners registered
	* for the event.
	* @param {...any} [args]
	* @returns {boolean}
	*/
	emit(type, ...args) {
		let doError = type === "error";
		const events = this._events;
		if (events !== undefined) {
			if (doError && events[kErrorMonitor] !== undefined) this.emit(kErrorMonitor, ...args);
			doError = doError && events.error === undefined;
		} else if (!doError) return false;
		if (doError) {
			let er;
			if (args.length > 0) er = args[0];
			if (er instanceof Error) {
				try {
					const capture = {};
					Error.captureStackTrace?.(capture, _EventEmitter.prototype.emit);
					Object.defineProperty(er, kEnhanceStackBeforeInspector, {
						__proto__: null,
						value: Function.prototype.bind(enhanceStackTrace, this, er, capture),
						configurable: true
					});
				} catch {}
				throw er;
			}
			let stringifiedEr;
			try {
				stringifiedEr = inspect(er);
			} catch {
				stringifiedEr = er;
			}
			const err = new ERR_UNHANDLED_ERROR(stringifiedEr);
			err.context = er;
			throw err;
		}
		const handler = events[type];
		if (handler === undefined) return false;
		if (typeof handler === "function") {
			const result = handler.apply(this, args);
			if (result !== undefined && result !== null) {
				addCatch(this, result, type, args);
			}
		} else {
			const len = handler.length;
			const listeners = arrayClone(handler);
			for (let i = 0; i < len; ++i) {
				const result = listeners[i].apply(this, args);
				if (result !== undefined && result !== null) {
					addCatch(this, result, type, args);
				}
			}
		}
		return true;
	}
	/**
	* Adds a listener to the event emitter.
	* @returns {EventEmitter}
	*/
	addListener(type, listener) {
		_addListener(this, type, listener, false);
		return this;
	}
	on(type, listener) {
		return this.addListener(type, listener);
	}
	/**
	* Adds the `listener` function to the beginning of
	* the listeners array.
	*/
	prependListener(type, listener) {
		_addListener(this, type, listener, true);
		return this;
	}
	/**
	* Adds a one-time `listener` function to the event emitter.
	*/
	once(type, listener) {
		checkListener(listener);
		this.on(type, _onceWrap(this, type, listener));
		return this;
	}
	/**
	* Adds a one-time `listener` function to the beginning of
	* the listeners array.
	*/
	prependOnceListener(type, listener) {
		checkListener(listener);
		this.prependListener(type, _onceWrap(this, type, listener));
		return this;
	}
	/**
	* Removes the specified `listener` from the listeners array.
	* @param {string | symbol} type
	* @param {Function} listener
	* @returns {EventEmitter}
	*/
	removeListener(type, listener) {
		checkListener(listener);
		const events = this._events;
		if (events === undefined) return this;
		const list = events[type];
		if (list === undefined) return this;
		if (list === listener || list.listener === listener) {
			this._eventsCount -= 1;
			if (this[kShapeMode]) {
				events[type] = undefined;
			} else if (this._eventsCount === 0) {
				this._events = { __proto__: null };
			} else {
				delete events[type];
				if (events.removeListener) this.emit("removeListener", type, list.listener || listener);
			}
		} else if (typeof list !== "function") {
			let position = -1;
			for (let i = list.length - 1; i >= 0; i--) {
				if (list[i] === listener || list[i].listener === listener) {
					position = i;
					break;
				}
			}
			if (position < 0) return this;
			if (position === 0) list.shift();
			else {
				spliceOne(list, position);
			}
			if (list.length === 1) events[type] = list[0];
			if (events.removeListener !== undefined) this.emit("removeListener", type, listener);
		}
		return this;
	}
	off(type, listener) {
		return this.removeListener(type, listener);
	}
	/**
	* Removes all listeners from the event emitter. (Only
	* removes listeners for a specific event name if specified
	* as `type`).
	*/
	removeAllListeners(type) {
		const events = this._events;
		if (events === undefined) return this;
		if (events.removeListener === undefined) {
			if (arguments.length === 0) {
				this._events = { __proto__: null };
				this._eventsCount = 0;
			} else if (events[type] !== undefined) {
				if (--this._eventsCount === 0) this._events = { __proto__: null };
				else delete events[type];
			}
			this[kShapeMode] = false;
			return this;
		}
		if (arguments.length === 0) {
			for (const key of Reflect.ownKeys(events)) {
				if (key === "removeListener") continue;
				this.removeAllListeners(key);
			}
			this.removeAllListeners("removeListener");
			this._events = { __proto__: null };
			this._eventsCount = 0;
			this[kShapeMode] = false;
			return this;
		}
		const listeners = events[type];
		if (typeof listeners === "function") {
			this.removeListener(type, listeners);
		} else if (listeners !== undefined) {
			for (let i = listeners.length - 1; i >= 0; i--) {
				this.removeListener(type, listeners[i]);
			}
		}
		return this;
	}
	/**
	* Returns a copy of the array of listeners for the event name
	* specified as `type`.
	* @param {string | symbol} type
	* @returns {Function[]}
	*/
	listeners(type) {
		return _listeners(this, type, true);
	}
	/**
	* Returns a copy of the array of listeners and wrappers for
	* the event name specified as `type`.
	* @returns {Function[]}
	*/
	rawListeners(type) {
		return _listeners(this, type, false);
	}
	/**
	* Returns an array listing the events for which
	* the emitter has registered listeners.
	* @returns {any[]}
	*/
	eventNames() {
		return this._eventsCount > 0 ? Reflect.ownKeys(this._events) : [];
	}
	/**
	* Returns the number of listeners listening to event name
	*/
	listenerCount(eventName, listener) {
		const events = this._events;
		if (events !== undefined) {
			const evlistener = events[eventName];
			if (typeof evlistener === "function") {
				if (listener != null) {
					return listener === evlistener || listener === evlistener.listener ? 1 : 0;
				}
				return 1;
			} else if (evlistener !== undefined) {
				if (listener != null) {
					let matching = 0;
					for (let i = 0, l = evlistener.length; i < l; i++) {
						if (evlistener[i] === listener || evlistener[i].listener === listener) {
							matching++;
						}
					}
					return matching;
				}
				return evlistener.length;
			}
		}
		return 0;
	}
}
export class EventEmitterAsyncResource extends _EventEmitter {
	/**
	* @param {{
	*   name?: string,
	*   triggerAsyncId?: number,
	*   requireManualDestroy?: boolean,
	* }} [options]
	*/
	constructor(options) {
		let name;
		if (typeof options === "string") {
			name = options;
			options = undefined;
		} else {
			name = options?.name || new.target.name;
		}
		super(options);
		this[kAsyncResource] = new EventEmitterReferencingAsyncResource(this, name, options);
	}
	/**
	* @param {symbol,string} event
	* @param  {...any} args
	* @returns {boolean}
	*/
	emit(event, ...args) {
		if (this[kAsyncResource] === undefined) throw new ERR_INVALID_THIS("EventEmitterAsyncResource");
		const { asyncResource } = this;
		Array.prototype.unshift(args, super.emit, this, event);
		return Reflect.apply(asyncResource.runInAsyncScope, asyncResource, args);
	}
	/**
	* @returns {void}
	*/
	emitDestroy() {
		if (this[kAsyncResource] === undefined) throw new ERR_INVALID_THIS("EventEmitterAsyncResource");
		this.asyncResource.emitDestroy();
	}
	/**
	* @type {number}
	*/
	get asyncId() {
		if (this[kAsyncResource] === undefined) throw new ERR_INVALID_THIS("EventEmitterAsyncResource");
		return this.asyncResource.asyncId();
	}
	/**
	* @type {number}
	*/
	get triggerAsyncId() {
		if (this[kAsyncResource] === undefined) throw new ERR_INVALID_THIS("EventEmitterAsyncResource");
		return this.asyncResource.triggerAsyncId();
	}
	/**
	* @type {EventEmitterReferencingAsyncResource}
	*/
	get asyncResource() {
		if (this[kAsyncResource] === undefined) throw new ERR_INVALID_THIS("EventEmitterAsyncResource");
		return this[kAsyncResource];
	}
}
class EventEmitterReferencingAsyncResource extends AsyncResource {
	/**
	* @param {EventEmitter} ee
	* @param {string} [type]
	* @param {{
	*   triggerAsyncId?: number,
	*   requireManualDestroy?: boolean,
	* }} [options]
	*/
	constructor(ee, type, options) {
		super(type, options);
		this[kEventEmitter] = ee;
	}
	/**
	* @type {EventEmitter}
	*/
	get eventEmitter() {
		if (this[kEventEmitter] === undefined) throw new ERR_INVALID_THIS("EventEmitterReferencingAsyncResource");
		return this[kEventEmitter];
	}
}
/**
* Returns an `AsyncIterator` that iterates `event` events.
* @param {EventEmitter} emitter
* @param {string | symbol} event
* @param {{
*    signal: AbortSignal;
*    close?: string[];
*    highWaterMark?: number,
*    lowWaterMark?: number
*   }} [options]
* @returns {AsyncIterator}
*/
export const on = function on(emitter, event, options = {}) {
	const signal = options.signal;
	if (signal?.aborted) {
		throw new AbortError(undefined, { cause: signal?.reason });
	}
	const highWatermark = options.highWaterMark ?? options.highWatermark ?? Number.MAX_SAFE_INTEGER;
	const lowWatermark = options.lowWaterMark ?? options.lowWatermark ?? 1;
	const unconsumedEvents = new FixedQueue();
	const unconsumedPromises = new FixedQueue();
	let paused = false;
	let error = null;
	let finished = false;
	let size = 0;
	const iterator = Object.setPrototypeOf({
		next() {
			if (size) {
				const value = unconsumedEvents.shift();
				size--;
				if (paused && size < lowWatermark) {
					emitter.resume?.();
					paused = false;
				}
				return Promise.resolve(createIterResult(value, false));
			}
			if (error) {
				const p = Promise.reject(error);
				error = null;
				return p;
			}
			if (finished) return closeHandler();
			return new Promise(function(resolve, reject) {
				unconsumedPromises.push({
					resolve,
					reject
				});
			});
		},
		return() {
			return closeHandler();
		},
		throw(err) {
			if (!err || !(err instanceof Error)) {
				throw new ERR_INVALID_ARG_TYPE(
					"EventEmitter.AsyncIterator",
					"Error",
					// @ts-expect-error
					err
);
			}
			errorHandler(err);
		},
		[Symbol.asyncIterator]() {
			return this;
		},
		[kWatermarkData]: {
			get size() {
				return size;
			},
			get low() {
				return lowWatermark;
			},
			get high() {
				return highWatermark;
			},
			get isPaused() {
				return paused;
			}
		}
	}, AsyncIteratorPrototype);
	const { addEventListener, removeAll } = listenersController();
	addEventListener(emitter, event, options[kFirstEventParam] ? eventHandler : function(...args) {
		return eventHandler(args);
	});
	if (event !== "error" && typeof emitter.on === "function") {
		addEventListener(emitter, "error", errorHandler);
	}
	const closeEvents = options?.close;
	if (closeEvents?.length) {
		for (const closeEvent of closeEvents) {
			addEventListener(emitter, closeEvent, closeHandler);
		}
	}
	const abortListenerDisposable = signal ? addAbortListener(signal, abortListener) : null;
	return iterator;
	function abortListener() {
		errorHandler(new AbortError(undefined, { cause: signal?.reason }));
	}
	function eventHandler(value) {
		if (unconsumedPromises.isEmpty()) {
			size++;
			if (!paused && size > highWatermark) {
				paused = true;
				emitter.pause?.();
			}
			unconsumedEvents.push(value);
		} else unconsumedPromises.shift().resolve(createIterResult(value, false));
	}
	function errorHandler(err) {
		if (unconsumedPromises.isEmpty()) error = err;
		else unconsumedPromises.shift().reject(err);
		closeHandler();
	}
	function closeHandler() {
		abortListenerDisposable?.[Symbol.dispose]();
		removeAll();
		finished = true;
		const doneResult = createIterResult(undefined, true);
		while (!unconsumedPromises.isEmpty()) {
			unconsumedPromises.shift().resolve(doneResult);
		}
		return Promise.resolve(doneResult);
	}
};
/**
* Creates a `Promise` that is fulfilled when the emitter
* emits the given event.
* @param {EventEmitter} emitter
* @param {string} name
* @param {{ signal: AbortSignal; }} [options]
* @returns {Promise}
*/
export const once = async function once(emitter, name, options = {}) {
	const signal = options?.signal;
	if (signal?.aborted) {
		throw new AbortError(undefined, { cause: signal?.reason });
	}
	return new Promise((resolve, reject) => {
		const errorListener = (err) => {
			if (typeof emitter.removeListener === "function") {
				emitter.removeListener(name, resolver);
			}
			if (signal != null) {
				eventTargetAgnosticRemoveListener(signal, "abort", abortListener);
			}
			reject(err);
		};
		const resolver = (...args) => {
			if (typeof emitter.removeListener === "function") {
				emitter.removeListener("error", errorListener);
			}
			if (signal != null) {
				eventTargetAgnosticRemoveListener(signal, "abort", abortListener);
			}
			resolve(args);
		};
		const opts = {
			__proto__: null,
			once: true,
			[kResistStopPropagation]: true
		};
		eventTargetAgnosticAddListener(emitter, name, resolver, opts);
		if (name !== "error" && typeof emitter.once === "function") {
			emitter.once("error", errorListener);
		}
		function abortListener() {
			eventTargetAgnosticRemoveListener(emitter, name, resolver);
			eventTargetAgnosticRemoveListener(emitter, "error", errorListener);
			reject(new AbortError(undefined, { cause: signal?.reason }));
		}
		if (signal != null) {
			eventTargetAgnosticAddListener(signal, "abort", abortListener, {
				__proto__: null,
				once: true,
				[kResistStopPropagation]: true
			});
		}
	});
};
export const addAbortListener = function addAbortListener(signal, listener) {
	if (signal === undefined) {
		throw new ERR_INVALID_ARG_TYPE("signal", "AbortSignal", signal);
	}
	let removeEventListener;
	if (signal.aborted) {
		queueMicrotask(() => listener());
	} else {
		signal.addEventListener("abort", listener, {
			__proto__: null,
			once: true,
			[kResistStopPropagation]: true
		});
		removeEventListener = () => {
			signal.removeEventListener("abort", listener);
		};
	}
	return {
		__proto__: null,
		[Symbol.dispose]() {
			removeEventListener?.();
		}
	};
};
/**
* Returns a copy of the array of listeners for the event name
* specified as `type`.
* @returns {Function[]}
*/
export const getEventListeners = function getEventListeners(emitterOrTarget, type) {
	if (typeof emitterOrTarget.listeners === "function") {
		return emitterOrTarget.listeners(type);
	}
	if (isEventTarget(emitterOrTarget)) {
		const root = emitterOrTarget[kEvents].get(type);
		const listeners = [];
		let handler = root?.next;
		while (handler?.listener !== undefined) {
			const listener = handler.listener?.deref ? handler.listener.deref() : handler.listener;
			listeners.push(listener);
			handler = handler.next;
		}
		return listeners;
	}
	throw new ERR_INVALID_ARG_TYPE(
		"emitter",
		["EventEmitter", "EventTarget"],
		// @ts-expect-error
		emitterOrTarget
);
};
/**
* Returns the max listeners set.
* @param {EventEmitter | EventTarget} emitterOrTarget
* @returns {number}
*/
export const getMaxListeners = function getMaxListeners(emitterOrTarget) {
	if (typeof emitterOrTarget?.getMaxListeners === "function") {
		return _getMaxListeners(emitterOrTarget);
	} else if (emitterOrTarget?.[kMaxEventTargetListeners]) {
		return emitterOrTarget[kMaxEventTargetListeners];
	}
	throw new ERR_INVALID_ARG_TYPE(
		"emitter",
		["EventEmitter", "EventTarget"],
		// @ts-expect-error
		emitterOrTarget
);
};
const kSize = 2048;
const kMask = kSize - 1;
class FixedCircularBuffer {
	bottom;
	top;
	list;
	next;
	constructor() {
		this.bottom = 0;
		this.top = 0;
		this.list = new Array(kSize);
		this.next = null;
	}
	isEmpty() {
		return this.top === this.bottom;
	}
	isFull() {
		return (this.top + 1 & kMask) === this.bottom;
	}
	push(data) {
		this.list[this.top] = data;
		this.top = this.top + 1 & kMask;
	}
	shift() {
		const nextItem = this.list[this.bottom];
		if (nextItem === undefined) return null;
		this.list[this.bottom] = undefined;
		this.bottom = this.bottom + 1 & kMask;
		return nextItem;
	}
}
class FixedQueue {
	head;
	tail;
	constructor() {
		this.head = this.tail = new FixedCircularBuffer();
	}
	isEmpty() {
		return this.head.isEmpty();
	}
	push(data) {
		if (this.head.isFull()) {
			this.head = this.head.next = new FixedCircularBuffer();
		}
		this.head.push(data);
	}
	shift() {
		const tail = this.tail;
		const next = tail.shift();
		if (tail.isEmpty() && tail.next !== null) {
			this.tail = tail.next;
			tail.next = null;
		}
		return next;
	}
}
function isEventTarget(emitter) {
	return typeof emitter?.addEventListener === "function";
}
function checkListener(listener) {}
function addCatch(that, promise, type, args) {
	if (!that[kCapture]) {
		return;
	}
	try {
		const then = promise.then;
		if (typeof then === "function") {
			then.call(promise, undefined, function(err) {
				setTimeout(emitUnhandledRejectionOrErr, 0, that, err, type, args);
			});
		}
	} catch (error_) {
		that.emit("error", error_);
	}
}
function emitUnhandledRejectionOrErr(ee, err, type, args) {
	if (typeof ee[kRejection] === "function") {
		ee[kRejection](err, type, ...args);
	} else {
		const prev = ee[kCapture];
		try {
			ee[kCapture] = false;
			ee.emit("error", err);
		} finally {
			ee[kCapture] = prev;
		}
	}
}
function _getMaxListeners(that) {
	if (that._maxListeners === undefined) return defaultMaxListeners;
	return that._maxListeners;
}
function enhanceStackTrace(err, own) {
	let ctorInfo = "";
	try {
		const { name } = this.constructor;
		if (name !== "EventEmitter") ctorInfo = ` on ${name} instance`;
	} catch {}
	const sep = `\nEmitted 'error' event${ctorInfo} at:\n`;
	const ownStack = (own.stack || "").split("\n").slice(1);
	return err.stack + sep + ownStack.join("\n");
}
function _addListener(target, type, listener, prepend) {
	let m;
	let events;
	let existing;
	checkListener(listener);
	events = target._events;
	if (events === undefined) {
		events = target._events = { __proto__: null };
		target._eventsCount = 0;
	} else {
		if (events.newListener !== undefined) {
			target.emit("newListener", type, listener.listener ?? listener);
			events = target._events;
		}
		existing = events[type];
	}
	if (existing === undefined) {
		events[type] = listener;
		++target._eventsCount;
	} else {
		if (typeof existing === "function") {
			existing = events[type] = prepend ? [listener, existing] : [existing, listener];
		} else if (prepend) {
			existing.unshift(listener);
		} else {
			existing.push(listener);
		}
		m = _getMaxListeners(target);
		if (m > 0 && existing.length > m && !existing.warned) {
			existing.warned = true;
			const w = new genericNodeError(`Possible EventEmitter memory leak detected. ${existing.length} ${String(type)} listeners ` + `added to ${inspect(target, { depth: -1 })}. MaxListeners is ${m}. Use emitter.setMaxListeners() to increase limit`, {
				name: "MaxListenersExceededWarning",
				emitter: target,
				type,
				count: existing.length
			});
			console.warn(w);
		}
	}
	return target;
}
function onceWrapper() {
	if (!this.fired) {
		this.target.removeListener(this.type, this.wrapFn);
		this.fired = true;
		if (arguments.length === 0) return this.listener.call(this.target);
		return this.listener.apply(this.target, arguments);
	}
}
function _onceWrap(target, type, listener) {
	const state = {
		fired: false,
		wrapFn: undefined,
		target,
		type,
		listener
	};
	const wrapped = onceWrapper.bind(state);
	wrapped.listener = listener;
	state.wrapFn = wrapped;
	return wrapped;
}
function _listeners(target, type, unwrap) {
	const events = target._events;
	if (events === undefined) return [];
	const evlistener = events[type];
	if (evlistener === undefined) return [];
	if (typeof evlistener === "function") return unwrap ? [evlistener.listener || evlistener] : [evlistener];
	return unwrap ? unwrapListeners(evlistener) : arrayClone(evlistener);
}
function arrayClone(arr) {
	switch (arr.length) {
		case 2: return [arr[0], arr[1]];
		case 3: return [
			arr[0],
			arr[1],
			arr[2]
		];
		case 4: return [
			arr[0],
			arr[1],
			arr[2],
			arr[3]
		];
		case 5: return [
			arr[0],
			arr[1],
			arr[2],
			arr[3],
			arr[4]
		];
		case 6: return [
			arr[0],
			arr[1],
			arr[2],
			arr[3],
			arr[4],
			arr[5]
		];
	}
	return Array.prototype.slice(arr);
}
function unwrapListeners(arr) {
	const ret = arrayClone(arr);
	for (let i = 0; i < ret.length; ++i) {
		const orig = ret[i].listener;
		if (typeof orig === "function") ret[i] = orig;
	}
	return ret;
}
function createIterResult(value, done) {
	return {
		value,
		done
	};
}
function eventTargetAgnosticRemoveListener(emitter, name, listener, flags) {
	if (typeof emitter.removeListener === "function") {
		emitter.removeListener(name, listener);
	} else if (typeof emitter.removeEventListener === "function") {
		emitter.removeEventListener(name, listener, flags);
	} else {
		throw new ERR_INVALID_ARG_TYPE("emitter", "EventEmitter", emitter);
	}
}
function eventTargetAgnosticAddListener(emitter, name, listener, flags) {
	if (typeof emitter.on === "function") {
		if (flags?.once) {
			emitter.once(name, listener);
		} else {
			emitter.on(name, listener);
		}
	} else if (typeof emitter.addEventListener === "function") {
		emitter.addEventListener(name, listener, flags);
	} else {
		throw new ERR_INVALID_ARG_TYPE("emitter", "EventEmitter", emitter);
	}
}
function listenersController() {
	const listeners = [];
	return {
		addEventListener(emitter, event, handler, flags) {
			eventTargetAgnosticAddListener(emitter, event, handler, flags);
			Array.prototype.push(listeners, [
				emitter,
				event,
				handler,
				flags
			]);
		},
		removeAll() {
			while (listeners.length > 0) {
				Reflect.apply(eventTargetAgnosticRemoveListener, undefined, listeners.pop());
			}
		}
	};
}
function spliceOne(list, index) {
	for (; index + 1 < list.length; index++) list[index] = list[index + 1];
	list.pop();
}
