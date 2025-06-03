import type nodeUrl from "node:url";
import * as querystring from "node:querystring";
import { fileURLToPath, urlToHttpOptions } from "./internal/url/url.mjs";
declare class Url implements nodeUrl.Url {
	auth: string | null;
	hash: string | null;
	host: string | null;
	hostname: string | null;
	href: string;
	path: string | null;
	pathname: string | null;
	protocol: string | null;
	search: string | null;
	slashes: boolean | null;
	port: string | null;
	query: string | querystring.ParsedUrlQuery | null;
	parse(url: string, parseQueryString?: boolean, slashesDenoteHost?: boolean);
	format();
	resolve(relative: string);
	resolveObject(relative: nodeUrl.Url);
	parseHost();
}
declare function urlParse(url: string | Url, parseQueryString?: boolean, slashesDenoteHost?: boolean): Url;
declare function urlFormat(urlObject: string | Url, options: nodeUrl.URLFormatOptions);
declare function urlResolve(source: string, relative: string);
declare function urlResolveObject(source: string, relative: nodeUrl.Url);
declare function pathToFileURL(path: string, options?: {
	windows?: boolean
});
declare const URL: unknown;
declare const URLSearchParams: unknown;
declare const domainToASCII: unknown;
declare const domainToUnicode: unknown;
export { Url, urlParse as parse, urlResolve as resolve, urlResolveObject as resolveObject, urlFormat as format, URL, URLSearchParams, domainToASCII, domainToUnicode, pathToFileURL, fileURLToPath, urlToHttpOptions };
declare const _default: {};
export default _default;
