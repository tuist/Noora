import type { MIMEType as MIMETypeT, MIMEParams as MIMEParamsT } from "node:util";
export declare class MIMEType implements MIMETypeT {
	readonly __unenv__: true;
	params;
	type: string;
	subtype: string;
	constructor(input: string | {
		toString: () => string
	});
	get essence();
	toString();
}
export declare class MIMEParams extends Map<string, string> implements MIMEParamsT {
	readonly __unenv__: true;
	get(name: string): any;
	toString();
}
