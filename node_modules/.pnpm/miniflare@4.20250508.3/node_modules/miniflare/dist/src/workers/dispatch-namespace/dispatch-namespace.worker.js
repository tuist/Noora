// src/workers/dispatch-namespace/dispatch-namespace.worker.ts
var LocalDispatchNamespace = class {
  constructor(env) {
    this.env = env;
  }
  get(name, args, options) {
    return {
      ...this.env.fetcher,
      fetch: (input, init) => {
        let request = new Request(input, init);
        return request.headers.set(
          "MF-Dispatch-Namespace-Options",
          JSON.stringify({ name, args, options })
        ), this.env.fetcher.fetch(request);
      }
    };
  }
};
function dispatch_namespace_worker_default(env) {
  return new LocalDispatchNamespace(env);
}
export {
  dispatch_namespace_worker_default as default
};
//# sourceMappingURL=dispatch-namespace.worker.js.map
