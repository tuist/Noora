import type nodeZlib from "node:zlib";
import { ZlibCompress, ZLibDecompress } from "./_shared.mjs";
export declare class Deflate extends ZlibCompress {
	readonly _format = "deflate";
	params(level: number, strategy: number, callback: () => void);
	reset();
}
export declare const deflate: typeof nodeZlib.deflate;
export declare const createDeflate: typeof nodeZlib.createDeflate;
export declare const deflateSync: typeof nodeZlib.deflateSync;
export declare class Inflate extends ZLibDecompress {
	readonly _format = "deflate";
	reset();
}
export declare const inflate: typeof nodeZlib.inflate;
export declare const createInflate: typeof nodeZlib.createInflate;
export declare const inflateSync: typeof nodeZlib.inflateSync;
export declare class DeflateRaw extends Deflate {}
export declare const deflateRaw: typeof nodeZlib.deflateRaw;
export declare const createDeflateRaw: typeof nodeZlib.createDeflateRaw;
export declare const deflateRawSync: typeof nodeZlib.deflateRawSync;
export declare class InflateRaw extends Inflate {}
export declare const inflateRaw: typeof nodeZlib.inflateRaw;
export declare const createInflateRaw: typeof nodeZlib.createInflateRaw;
export declare const inflateRawSync: typeof nodeZlib.inflateRawSync;
