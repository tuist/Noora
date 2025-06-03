import type nodePerfHooks from "node:perf_hooks";
export declare class PerformanceEntry implements nodePerfHooks.PerformanceEntry {
	readonly __unenv__: true;
	detail: any | undefined;
	entryType: any;
	name: string;
	startTime: number;
	constructor(name: string, options?: PerformanceMarkOptions);
	get duration(): number;
	toJSON(): {};
}
export declare const PerformanceMark: typeof nodePerfHooks.PerformanceMark;
export declare class PerformanceMeasure extends PerformanceEntry implements globalThis.PerformanceMeasure {
	entryType: "measure";
}
export declare class PerformanceResourceTiming extends PerformanceEntry implements globalThis.PerformanceResourceTiming {
	entryType: "resource";
	serverTiming: readonly PerformanceServerTiming[];
	connectEnd: number;
	connectStart: number;
	decodedBodySize: number;
	domainLookupEnd: number;
	domainLookupStart: number;
	encodedBodySize: number;
	fetchStart: number;
	initiatorType: string;
	name: string;
	nextHopProtocol: string;
	redirectEnd: number;
	redirectStart: number;
	requestStart: number;
	responseEnd: number;
	responseStart: number;
	secureConnectionStart: number;
	startTime: number;
	transferSize: number;
	workerStart: number;
	responseStatus: number;
}
export declare class PerformanceObserverEntryList implements globalThis.PerformanceObserverEntryList {
	readonly __unenv__: true;
	getEntries(): PerformanceEntryList;
	getEntriesByName(_name: string, _type?: string | undefined): PerformanceEntryList;
	getEntriesByType(type: string): PerformanceEntryList;
}
export declare class Performance implements nodePerfHooks.Performance {
	readonly __unenv__: true;
	timeOrigin: number;
	eventCounts: EventCounts;
	_entries: PerformanceEntry[];
	_resourceTimingBufferSize: number;
	navigation: any;
	timing: any;
	timerify<T extends (...params: any[]) => any>(_fn: T, _options?: nodePerfHooks.TimerifyOptions | undefined): T;
	get nodeTiming(): nodePerfHooks.PerformanceNodeTiming;
	eventLoopUtilization(): nodePerfHooks.EventLoopUtilization;
	markResourceTiming(): nodePerfHooks.PerformanceResourceTiming;
	onresourcetimingbufferfull: ((this: Performance, ev: Event) => any) | null;
	now(): number;
	clearMarks(markName?: string | undefined): void;
	clearMeasures(measureName?: string | undefined): void;
	clearResourceTimings(): void;
	getEntries(): any;
	getEntriesByName(name: string, type?: string | undefined): any;
	getEntriesByType(type: string): any[];
	mark(name: string, options?: PerformanceMarkOptions | undefined): any;
	measure(measureName: string, startOrMeasureOptions?: string | PerformanceMeasureOptions, endMark?: string);
	setResourceTimingBufferSize(maxSize: number): void;
	addEventListener<K extends "resourcetimingbufferfull">(type: K, listener: (this: Performance, ev: PerformanceEventMap[K]) => any, options?: boolean | AddEventListenerOptions | undefined): void;
	addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions | undefined): void;
	removeEventListener<K extends "resourcetimingbufferfull">(type: K, listener: (this: Performance, ev: PerformanceEventMap[K]) => any, options?: boolean | EventListenerOptions | undefined): void;
	removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions | undefined): void;
	dispatchEvent(event: Event): boolean;
	toJSON();
}
export declare class PerformanceObserver implements nodePerfHooks.PerformanceObserver {
	readonly __unenv__: true;
	static supportedEntryTypes: ReadonlyArray<string>;
	_callback: PerformanceObserverCallback | null;
	constructor(callback: PerformanceObserverCallback);
	takeRecords(): unknown;
	disconnect(): void;
	observe(options: any);
	bind<Func extends (...args: any[]) => any>(fn: Func): Func;
	runInAsyncScope<
		This,
		Result
	>(fn: (this: This, ...args: any[]) => Result, thisArg?: This | undefined, ...args: any[]);
	asyncId(): number;
	triggerAsyncId(): number;
	emitDestroy(): this;
}
export declare const performance: unknown;
