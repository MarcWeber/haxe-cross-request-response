package web;
#if NODE_JS
import js.Node;
#end

// Minimal stateful thing knowing how to retrieve get/post/path data
// and knowing how to send a reply to the server.

// The code actually returning useful things such as get vars etc
// can be found in RequestResponseHelper. I hope this is a minimal desgin
// nodejs causes some overhead, some targets such as PHP don't require any
// state, thus the class is just a dummy type

class RequestState {

  #if NODE_JS
  public var urlObj: js.Node.NodeUrlObj;
  public var request: js.NodeHttpServerReq;
  public var response: js.NodeHttpServerResp;
  #elseif neko
  public var paramValues: Map<String,String>;
  #elseif JAVA_NANOHTTPD
  public var response: fi.iki.elonen.NanoHTTPD_Response;
  #end

  #if js
  public function new(request)
  #else
  public function new()
  #end
  {
  #if js
    this.request = request;
    // this is very likely to be used, so do it once
    this.urlObj = js.Node.url.parse(request.url);
  #elseif neko
    this.paramValues = neko.Web.getParams();
  #end
  }
}
