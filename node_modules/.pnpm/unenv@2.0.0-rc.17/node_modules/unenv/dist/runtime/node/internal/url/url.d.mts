export declare const unsafeProtocol: unknown;
export declare const hostlessProtocol: unknown;
export declare const slashedProtocol: unknown;
export declare function pathToFileURL(filepath: string, options?: {
	windows?: boolean
});
export declare function fileURLToPath(path: string | URL, options?: {
	windows?: boolean
});
/**
* Utility function that converts a URL object into an ordinary options object
* as expected by the `http.request` and `https.request` APIs.
* @param {URL} url
* @returns {Record<string, unknown>}
*/
export declare function urlToHttpOptions(url: URL): {
	__proto__: null
	path: string
};
