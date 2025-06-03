// templates/startDevWorker/InspectorProxyWorker.ts
import assert2 from "node:assert";

// src/api/startDevWorker/events.ts
function serialiseError(e) {
  if (e instanceof Error) {
    return {
      message: e.message,
      name: e.name,
      stack: e.stack,
      cause: e.cause && serialiseError(e.cause)
    };
  } else {
    return { message: String(e) };
  }
}

// src/api/startDevWorker/utils.ts
import assert from "node:assert";
function createDeferred(previousDeferred) {
  let resolve, reject;
  const newPromise = new Promise((_resolve, _reject) => {
    resolve = _resolve;
    reject = _reject;
  });
  assert(resolve);
  assert(reject);
  previousDeferred?.resolve(newPromise);
  return {
    promise: newPromise,
    resolve,
    reject
  };
}
function assertNever(_value) {
}
function urlFromParts(parts, base = "http://localhost") {
  const url = new URL(base);
  Object.assign(url, parts);
  return url;
}

// templates/startDevWorker/InspectorProxyWorker.ts
var ALLOWED_HOST_HOSTNAMES = ["127.0.0.1", "[::1]", "localhost"];
var ALLOWED_ORIGIN_HOSTNAMES = [
  "devtools.devprod.cloudflare.dev",
  "cloudflare-devtools.pages.dev",
  /^[a-z0-9]+\.cloudflare-devtools\.pages\.dev$/,
  "127.0.0.1",
  "[::1]",
  "localhost"
];
var InspectorProxyWorker_default = {
  fetch(req, env) {
    const singleton = env.DURABLE_OBJECT.idFromName("");
    const inspectorProxy = env.DURABLE_OBJECT.get(singleton);
    return inspectorProxy.fetch(req);
  }
};
function isDevToolsEvent(event, name) {
  return typeof event === "object" && event !== null && "method" in event && event.method === name;
}
var InspectorProxyWorker = class {
  constructor(_state, env) {
    this.env = env;
  }
  websockets = {
    runtimeDeferred: createDeferred()
  };
  proxyData;
  runtimeMessageBuffer = [];
  // Only allow a limited number of error-based reconnections, so as not to infinite loop
  reconnectionsRemaining = 3;
  async fetch(req) {
    if (req.headers.get("Authorization") === this.env.PROXY_CONTROLLER_AUTH_SECRET) {
      return this.handleProxyControllerRequest(req);
    }
    if (req.headers.get("Upgrade") === "websocket") {
      return this.handleDevToolsWebSocketUpgradeRequest(req);
    }
    return this.handleDevToolsJsonRequest(req);
  }
  // ************************
  // **  PROXY CONTROLLER  **
  // ************************
  handleProxyControllerRequest(req) {
    assert2(
      req.headers.get("Upgrade") === "websocket",
      "Expected proxy controller data request to be WebSocket upgrade"
    );
    const { 0: response, 1: proxyController } = new WebSocketPair();
    proxyController.accept();
    proxyController.addEventListener("close", (event) => {
      this.sendDebugLog(
        "PROXY CONTROLLER WEBSOCKET CLOSED",
        event.code,
        event.reason
      );
      if (this.websockets.proxyController === proxyController) {
        this.websockets.proxyController = void 0;
      }
    });
    proxyController.addEventListener("error", (event) => {
      const error = serialiseError(event.error);
      this.sendDebugLog("PROXY CONTROLLER WEBSOCKET ERROR", error);
      if (this.websockets.proxyController === proxyController) {
        this.websockets.proxyController = void 0;
      }
    });
    proxyController.addEventListener(
      "message",
      this.handleProxyControllerIncomingMessage
    );
    this.websockets.proxyController = proxyController;
    return new Response(null, {
      status: 101,
      webSocket: response
    });
  }
  handleProxyControllerIncomingMessage = (event) => {
    assert2(
      typeof event.data === "string",
      "Expected event.data from proxy controller to be string"
    );
    const message = JSON.parse(
      event.data
    );
    this.sendDebugLog("handleProxyControllerIncomingMessage", event.data);
    switch (message.type) {
      case "reloadStart": {
        this.sendRuntimeDiscardConsoleEntries();
        break;
      }
      case "reloadComplete": {
        this.proxyData = message.proxyData;
        this.reconnectRuntimeWebSocket();
        break;
      }
      default: {
        assertNever(message);
      }
    }
  };
  sendProxyControllerMessage(message) {
    message = typeof message === "string" ? message : JSON.stringify(message);
    this.websockets.proxyController?.send(message);
  }
  async sendProxyControllerRequest(message) {
    try {
      const res = await this.env.PROXY_CONTROLLER.fetch("http://dummy", {
        method: "POST",
        body: JSON.stringify(message)
      });
      return res.ok ? await res.text() : void 0;
    } catch (e) {
      this.sendDebugLog(
        "FAILED TO SEND PROXY CONTROLLER REQUEST",
        serialiseError(e)
      );
      return void 0;
    }
  }
  sendDebugLog = (...args) => {
    this.sendProxyControllerRequest({ type: "debug-log", args });
  };
  // ***************
  // **  RUNTIME  **
  // ***************
  handleRuntimeIncomingMessage = (event) => {
    assert2(typeof event.data === "string");
    const msg = JSON.parse(event.data);
    this.sendDebugLog("RUNTIME INCOMING MESSAGE", msg);
    if (isDevToolsEvent(msg, "Runtime.exceptionThrown")) {
      this.sendProxyControllerMessage(event.data);
    }
    if (this.proxyData?.proxyLogsToController && isDevToolsEvent(msg, "Runtime.consoleAPICalled")) {
      this.sendProxyControllerMessage(event.data);
    }
    this.runtimeMessageBuffer.push(msg);
    this.tryDrainRuntimeMessageBuffer();
  };
  handleRuntimeScriptParsed(msg) {
    if (!this.websockets.devtoolsHasFileSystemAccess && msg.params.sourceMapURL !== void 0 && // Don't try to find a sourcemap for e.g. node-internal: scripts
    msg.params.url.startsWith("file:")) {
      const url = new URL(msg.params.sourceMapURL, msg.params.url);
      if (url.protocol === "file:") {
        msg.params.sourceMapURL = url.href.replace("file:", "wrangler-file:");
      }
    }
    void this.sendDevToolsMessage(msg);
  }
  tryDrainRuntimeMessageBuffer = () => {
    if (this.websockets.devtools === void 0) return;
    for (const msg of this.runtimeMessageBuffer.splice(0)) {
      if (isDevToolsEvent(msg, "Debugger.scriptParsed")) {
        this.handleRuntimeScriptParsed(msg);
      } else {
        void this.sendDevToolsMessage(msg);
      }
    }
  };
  runtimeAbortController = new AbortController();
  // will abort the in-flight websocket upgrade request to the remote runtime
  runtimeKeepAliveInterval = null;
  async reconnectRuntimeWebSocket() {
    assert2(this.proxyData, "Expected this.proxyData to be defined");
    this.sendDebugLog("reconnectRuntimeWebSocket");
    this.websockets.runtime?.close();
    this.websockets.runtime = void 0;
    this.runtimeAbortController.abort();
    this.runtimeAbortController = new AbortController();
    this.websockets.runtimeDeferred = createDeferred(
      this.websockets.runtimeDeferred
    );
    const runtimeWebSocketUrl = urlFromParts(
      this.proxyData.userWorkerInspectorUrl
    );
    runtimeWebSocketUrl.protocol = this.proxyData.userWorkerUrl.protocol;
    this.sendDebugLog("NEW RUNTIME WEBSOCKET", runtimeWebSocketUrl);
    this.sendDevToolsMessage({
      method: "Runtime.executionContextsCleared",
      params: void 0
    });
    const upgrade = await fetch(runtimeWebSocketUrl, {
      headers: {
        ...this.proxyData.headers,
        Upgrade: "websocket"
      },
      signal: this.runtimeAbortController.signal
    });
    const runtime = upgrade.webSocket;
    if (!runtime) {
      const error = new Error(
        `Failed to establish the WebSocket connection: expected server to reply with HTTP status code 101 (switching protocols), but received ${upgrade.status} instead.`
      );
      if (upgrade.status === 502 && this.reconnectionsRemaining >= 0) {
        await scheduler.wait((3 - this.reconnectionsRemaining) * 1e3);
        this.sendDebugLog(
          "RECONNECTING RUNTIME WEBSOCKET after 502. Reconnections remaining:",
          this.reconnectionsRemaining
        );
        return this.reconnectRuntimeWebSocket();
      }
      this.websockets.runtimeDeferred.reject(error);
      this.sendProxyControllerRequest({
        type: "runtime-websocket-error",
        error: serialiseError(error)
      });
      return;
    }
    this.websockets.runtime = runtime;
    runtime.addEventListener("message", this.handleRuntimeIncomingMessage);
    runtime.addEventListener("close", (event) => {
      this.sendDebugLog("RUNTIME WEBSOCKET CLOSED", event.code, event.reason);
      clearInterval(this.runtimeKeepAliveInterval);
      if (this.websockets.runtime === runtime) {
        this.websockets.runtime = void 0;
      }
    });
    runtime.addEventListener("error", (event) => {
      const error = serialiseError(event.error);
      this.sendDebugLog("RUNTIME WEBSOCKET ERROR", error);
      clearInterval(this.runtimeKeepAliveInterval);
      if (this.websockets.runtime === runtime) {
        this.websockets.runtime = void 0;
      }
      this.sendProxyControllerRequest({
        type: "runtime-websocket-error",
        error
      });
    });
    runtime.accept();
    this.handleRuntimeWebSocketOpen(runtime);
  }
  #runtimeMessageCounter = 1e8;
  nextCounter() {
    return ++this.#runtimeMessageCounter;
  }
  handleRuntimeWebSocketOpen(runtime) {
    this.sendDebugLog("RUNTIME WEBSOCKET OPENED");
    this.reconnectionsRemaining = 3;
    this.sendRuntimeMessage(
      { method: "Runtime.enable", id: this.nextCounter() },
      runtime
    );
    this.sendRuntimeMessage(
      { method: "Debugger.enable", id: this.nextCounter() },
      runtime
    );
    this.sendRuntimeMessage(
      { method: "Network.enable", id: this.nextCounter() },
      runtime
    );
    clearInterval(this.runtimeKeepAliveInterval);
    this.runtimeKeepAliveInterval = setInterval(() => {
      this.sendRuntimeMessage(
        { method: "Runtime.getIsolateId", id: this.nextCounter() },
        runtime
      );
    }, 1e4);
    this.websockets.runtimeDeferred.resolve(runtime);
  }
  sendRuntimeDiscardConsoleEntries() {
    if (this.websockets.runtime) {
      this.sendRuntimeMessage(
        {
          method: "Runtime.discardConsoleEntries",
          id: this.nextCounter()
        },
        this.websockets.runtime
      );
    }
  }
  async sendRuntimeMessage(message, runtime = this.websockets.runtimeDeferred.promise) {
    runtime = await runtime;
    message = typeof message === "string" ? message : JSON.stringify(message);
    this.sendDebugLog("SEND TO RUNTIME", message);
    runtime.send(message);
  }
  // ****************
  // **  DEVTOOLS  **
  // ****************
  #inspectorId = crypto.randomUUID();
  async handleDevToolsJsonRequest(req) {
    const url = new URL(req.url);
    if (url.pathname === "/json/version") {
      return Response.json({
        Browser: `wrangler/v${this.env.WRANGLER_VERSION}`,
        // TODO: (someday): The DevTools protocol should match that of workerd.
        // This could be exposed by the preview API.
        "Protocol-Version": "1.3"
      });
    }
    if (url.pathname === "/json" || url.pathname === "/json/list") {
      const localHost = `${url.host}/ws`;
      const devtoolsFrontendUrl = `https://devtools.devprod.cloudflare.dev/js_app?theme=systemPreferred&debugger=true&ws=${localHost}`;
      return Response.json([
        {
          id: this.#inspectorId,
          type: "node",
          // TODO: can we specify different type?
          description: "workers",
          webSocketDebuggerUrl: `ws://${localHost}`,
          devtoolsFrontendUrl,
          devtoolsFrontendUrlCompat: devtoolsFrontendUrl,
          // Below are fields that are visible in the DevTools UI.
          title: "Cloudflare Worker",
          faviconUrl: "https://workers.cloudflare.com/favicon.ico"
          // url: "http://" + localHost, // looks unnecessary
        }
      ]);
    }
    return new Response(null, { status: 404 });
  }
  async handleDevToolsWebSocketUpgradeRequest(req) {
    let hostHeader = req.headers.get("Host");
    if (hostHeader == null) return new Response(null, { status: 400 });
    try {
      const host = new URL(`http://${hostHeader}`);
      if (!ALLOWED_HOST_HOSTNAMES.includes(host.hostname)) {
        return new Response("Disallowed `Host` header", { status: 401 });
      }
    } catch {
      return new Response("Expected `Host` header", { status: 400 });
    }
    let originHeader = req.headers.get("Origin");
    if (originHeader === null && !req.headers.has("User-Agent")) {
      originHeader = "http://localhost";
    }
    if (originHeader === null) {
      return new Response("Expected `Origin` header", { status: 400 });
    }
    try {
      const origin = new URL(originHeader);
      const allowed = ALLOWED_ORIGIN_HOSTNAMES.some((rule) => {
        if (typeof rule === "string") return origin.hostname === rule;
        else return rule.test(origin.hostname);
      });
      if (!allowed) {
        return new Response("Disallowed `Origin` header", { status: 401 });
      }
    } catch {
      return new Response("Expected `Origin` header", { status: 400 });
    }
    this.sendDebugLog("DEVTOOLS WEBSOCKET TRYING TO CONNECT");
    await this.websockets.runtimeDeferred.promise;
    this.sendDebugLog("DEVTOOLS WEBSOCKET CAN NOW CONNECT");
    assert2(
      req.headers.get("Upgrade") === "websocket",
      "Expected DevTools connection to be WebSocket upgrade"
    );
    const { 0: response, 1: devtools } = new WebSocketPair();
    devtools.accept();
    if (this.websockets.devtools !== void 0) {
      devtools.close(
        1013,
        "Too many clients; only one can be connected at a time"
      );
    } else {
      devtools.addEventListener("message", this.handleDevToolsIncomingMessage);
      devtools.addEventListener("close", (event) => {
        this.sendDebugLog(
          "DEVTOOLS WEBSOCKET CLOSED",
          event.code,
          event.reason
        );
        if (this.websockets.devtools === devtools) {
          this.websockets.devtools = void 0;
        }
      });
      devtools.addEventListener("error", (event) => {
        const error = serialiseError(event.error);
        this.sendDebugLog("DEVTOOLS WEBSOCKET ERROR", error);
        if (this.websockets.devtools === devtools) {
          this.websockets.devtools = void 0;
        }
      });
      this.sendRuntimeMessage({
        id: this.nextCounter(),
        method: "Debugger.disable"
      });
      this.sendDebugLog("DEVTOOLS WEBSOCKET CONNECTED");
      const userAgent = req.headers.get("User-Agent") ?? "";
      const hasFileSystemAccess = !/mozilla/i.test(userAgent);
      this.websockets.devtools = devtools;
      this.websockets.devtoolsHasFileSystemAccess = hasFileSystemAccess;
      this.tryDrainRuntimeMessageBuffer();
    }
    return new Response(null, { status: 101, webSocket: response });
  }
  handleDevToolsIncomingMessage = (event) => {
    assert2(
      typeof event.data === "string",
      "Expected devtools incoming message to be of type string"
    );
    const message = JSON.parse(event.data);
    this.sendDebugLog("DEVTOOLS INCOMING MESSAGE", message);
    if (message.method === "Network.loadNetworkResource") {
      return void this.handleDevToolsLoadNetworkResource(message);
    }
    this.sendRuntimeMessage(JSON.stringify(message));
  };
  async handleDevToolsLoadNetworkResource(message) {
    const response = await this.sendProxyControllerRequest({
      type: "load-network-resource",
      url: message.params.url
    });
    if (response === void 0) {
      this.sendDebugLog(
        `ProxyController could not resolve Network.loadNetworkResource for "${message.params.url}"`
      );
      this.sendRuntimeMessage(JSON.stringify(message));
    } else {
      this.sendDevToolsMessage({
        id: message.id,
        // @ts-expect-error DevTools Protocol type does not match our patched devtools -- result.resource.text was added
        result: { resource: { success: true, text: response } }
      });
    }
  }
  sendDevToolsMessage(message) {
    message = typeof message === "string" ? message : JSON.stringify(message);
    this.sendDebugLog("SEND TO DEVTOOLS", message);
    this.websockets.devtools?.send(message);
  }
};
export {
  InspectorProxyWorker,
  InspectorProxyWorker_default as default
};
