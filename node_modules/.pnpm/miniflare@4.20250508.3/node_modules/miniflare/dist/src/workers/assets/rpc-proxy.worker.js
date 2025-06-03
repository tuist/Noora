// src/workers/assets/rpc-proxy.worker.ts
import { WorkerEntrypoint } from "cloudflare:workers";
var RPCProxyWorker = class extends WorkerEntrypoint {
  async fetch(request) {
    return this.env.ROUTER_WORKER.fetch(request);
  }
  constructor(ctx, env) {
    return super(ctx, env), new Proxy(this, {
      get(target, prop) {
        return Reflect.has(target, prop) ? Reflect.get(target, prop) : Reflect.get(target.env.USER_WORKER, prop);
      }
    });
  }
};
export {
  RPCProxyWorker as default
};
//# sourceMappingURL=rpc-proxy.worker.js.map
