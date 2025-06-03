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
function urlFromParts(parts, base = "http://localhost") {
  const url = new URL(base);
  Object.assign(url, parts);
  return url;
}

// templates/startDevWorker/ProxyWorker.ts
var LIVE_RELOAD_PROTOCOL = "WRANGLER_PROXYWORKER_LIVE_RELOAD_PROTOCOL";
var ProxyWorker_default = {
  fetch(req, env) {
    const singleton = env.DURABLE_OBJECT.idFromName("");
    const inspectorProxy = env.DURABLE_OBJECT.get(singleton);
    return inspectorProxy.fetch(req);
  }
};
var ProxyWorker = class {
  constructor(state, env) {
    this.state = state;
    this.env = env;
  }
  proxyData;
  requestQueue = /* @__PURE__ */ new Map();
  requestRetryQueue = /* @__PURE__ */ new Map();
  fetch(request) {
    if (isRequestForLiveReloadWebsocket(request)) {
      return this.handleLiveReloadWebSocket(request);
    }
    if (isRequestFromProxyController(request, this.env)) {
      return this.processProxyControllerRequest(request);
    }
    const deferred = createDeferred();
    this.requestQueue.set(request, deferred);
    this.processQueue();
    return deferred.promise;
  }
  handleLiveReloadWebSocket(request) {
    const { 0: response, 1: liveReload } = new WebSocketPair();
    const websocketProtocol = request.headers.get("Sec-WebSocket-Protocol") ?? "";
    this.state.acceptWebSocket(liveReload, ["live-reload"]);
    return new Response(null, {
      status: 101,
      webSocket: response,
      headers: { "Sec-WebSocket-Protocol": websocketProtocol }
    });
  }
  processProxyControllerRequest(request) {
    const event = request.cf?.hostMetadata;
    switch (event?.type) {
      case "pause":
        this.proxyData = void 0;
        break;
      case "play":
        this.proxyData = event.proxyData;
        this.processQueue();
        this.state.getWebSockets("live-reload").forEach((ws) => ws.send("reload"));
        break;
    }
    return new Response(null, { status: 204 });
  }
  /**
   * Process requests that are being retried first, then process newer requests.
   * Requests that are being retried are, by definition, older than requests which haven't been processed yet.
   * We don't need to be more accurate than this re ordering, since the requests are being fired off synchronously.
   */
  *getOrderedQueue() {
    yield* this.requestRetryQueue;
    yield* this.requestQueue;
  }
  processQueue() {
    const { proxyData } = this;
    if (proxyData === void 0) return;
    for (const [request, deferredResponse] of this.getOrderedQueue()) {
      this.requestRetryQueue.delete(request);
      this.requestQueue.delete(request);
      const outerUrl = new URL(request.url);
      const headers = new Headers(request.headers);
      const userWorkerUrl = new URL(request.url);
      Object.assign(userWorkerUrl, proxyData.userWorkerUrl);
      const innerUrl = urlFromParts(
        proxyData.userWorkerInnerUrlOverrides ?? {},
        request.url
      );
      headers.set("MF-Original-URL", innerUrl.href);
      headers.set("MF-Disable-Pretty-Error", "true");
      const encoding = request.cf?.clientAcceptEncoding;
      if (encoding !== void 0) headers.set("Accept-Encoding", encoding);
      rewriteUrlRelatedHeaders(headers, outerUrl, innerUrl);
      for (const [key, value] of Object.entries(proxyData.headers ?? {})) {
        if (value === void 0) continue;
        if (key.toLowerCase() === "cookie") {
          const existing = request.headers.get("cookie") ?? "";
          headers.set("cookie", `${existing};${value}`);
        } else {
          headers.set(key, value);
        }
      }
      void fetch(userWorkerUrl, new Request(request, { headers })).then((res) => {
        res = new Response(res.body, res);
        rewriteUrlRelatedHeaders(res.headers, innerUrl, outerUrl);
        if (isHtmlResponse(res)) {
          res = insertLiveReloadScript(request, res, this.env, proxyData);
        }
        deferredResponse.resolve(res);
      }).catch((error) => {
        const newUserWorkerUrl = this.proxyData && urlFromParts(this.proxyData.userWorkerUrl);
        if (userWorkerUrl.href === newUserWorkerUrl?.href) {
          void sendMessageToProxyController(this.env, {
            type: "error",
            error: {
              name: error.name,
              message: error.message,
              stack: error.stack,
              cause: error.cause
            }
          });
          deferredResponse.reject(error);
        } else if (request.method === "GET" || request.method === "HEAD") {
          this.requestRetryQueue.set(request, deferredResponse);
        } else {
          deferredResponse.resolve(
            new Response(
              "Your worker restarted mid-request. Please try sending the request again. Only GET or HEAD requests are retried automatically.",
              {
                status: 503,
                headers: { "Retry-After": "0" }
              }
            )
          );
        }
      });
    }
  }
};
function isRequestFromProxyController(req, env) {
  return req.headers.get("Authorization") === env.PROXY_CONTROLLER_AUTH_SECRET;
}
function isHtmlResponse(res) {
  return res.headers.get("content-type")?.startsWith("text/html") ?? false;
}
function isRequestForLiveReloadWebsocket(req) {
  const websocketProtocol = req.headers.get("Sec-WebSocket-Protocol");
  const isWebSocketUpgrade = req.headers.get("Upgrade") === "websocket";
  return isWebSocketUpgrade && websocketProtocol === LIVE_RELOAD_PROTOCOL;
}
function sendMessageToProxyController(env, message) {
  return env.PROXY_CONTROLLER.fetch("http://dummy", {
    method: "POST",
    body: JSON.stringify(message)
  });
}
function insertLiveReloadScript(request, response, env, proxyData) {
  const htmlRewriter = new HTMLRewriter();
  let errorDetails = "";
  htmlRewriter.on("#cf-error-details", {
    text(element) {
      errorDetails += element.text;
    }
  });
  htmlRewriter.onDocument({
    end(end) {
      if (response.status === 400 && errorDetails.includes("Invalid Workers Preview configuration")) {
        void sendMessageToProxyController(env, {
          type: "previewTokenExpired",
          proxyData
        });
      }
      if (proxyData.liveReload) {
        const websocketUrl = new URL(request.url);
        websocketUrl.protocol = websocketUrl.protocol === "http:" ? "ws:" : "wss:";
        end.append(liveReloadScript, { html: true });
      }
    }
  });
  return htmlRewriter.transform(response);
}
var liveReloadScript = `
<script defer type="application/javascript">
	(function() {
		var ws;
		function recover() {
			ws = null;
			setTimeout(initLiveReload, 100);
		}
		function initLiveReload() {
			if (ws) return;
			var origin = (location.protocol === "http:" ? "ws://" : "wss://") + location.host;
			ws = new WebSocket(origin + "/cdn-cgi/live-reload", "${LIVE_RELOAD_PROTOCOL}");
			ws.onclose = recover;
			ws.onerror = recover;
			ws.onmessage = location.reload.bind(location);
		}
		initLiveReload();
	})();
</script>
`;
function rewriteUrlRelatedHeaders(headers, from, to) {
  const setCookie = headers.getAll("Set-Cookie");
  headers.delete("Set-Cookie");
  headers.forEach((value, key) => {
    if (typeof value === "string" && value.includes(from.host)) {
      headers.set(
        key,
        value.replaceAll(from.origin, to.origin).replaceAll(from.host, to.host)
      );
    }
  });
  for (const cookie of setCookie) {
    headers.append(
      "Set-Cookie",
      cookie.replace(
        new RegExp(`Domain=${from.hostname}($|;|,)`),
        `Domain=${to.hostname}$1`
      )
    );
  }
}
export {
  ProxyWorker,
  ProxyWorker_default as default
};
