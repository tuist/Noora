import { notImplemented } from "../../../../_internal/utils.mjs";
import { ZlibCompress, ZLibDecompress, notImplementedCompress } from "./_shared.mjs";
export class BrotliCompress extends ZlibCompress {
	_format = "brotli";
}
export const brotliCompress = notImplementedCompress("brotliCompress");
export const createBrotliCompress = () => new BrotliCompress();
export const brotliCompressSync = /* @__PURE__ */ notImplemented("zlib.brotliCompressSync");
export class BrotliDecompress extends ZLibDecompress {
	_format = "brotli";
}
export const brotliDecompress = notImplementedCompress("brotliDecompress");
export const createBrotliDecompress = () => new BrotliDecompress();
export const brotliDecompressSync = /* @__PURE__ */ notImplemented("zlib.brotliDecompressSync");
