import type nodeDiagnosticsChannel from "node:diagnostics_channel";
export { Channel } from "./internal/diagnostics_channel/channel.mjs";
export declare const channel: typeof nodeDiagnosticsChannel.channel;
export declare const hasSubscribers: typeof nodeDiagnosticsChannel.hasSubscribers;
export declare const subscribe: typeof nodeDiagnosticsChannel.subscribe;
export declare const unsubscribe: typeof nodeDiagnosticsChannel.unsubscribe;
export declare const tracingChannel: typeof nodeDiagnosticsChannel.tracingChannel;
declare const _default: {};
export default _default;
