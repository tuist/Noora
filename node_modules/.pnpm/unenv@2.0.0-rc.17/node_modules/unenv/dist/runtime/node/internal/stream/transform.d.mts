import type nodeStream from "node:stream";
import { Duplex } from "./duplex.mjs";
export declare class _Transform extends Duplex implements nodeStream.Transform {
	readonly __unenv__: true;
	_transform(chunk: any, encoding: globalThis.BufferEncoding, callback: nodeStream.TransformCallback): void;
	_flush(callback: nodeStream.TransformCallback): void;
}
export declare const Transform: typeof nodeStream.Transform;
