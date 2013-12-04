package web;
#if js
import js.Node;
#end

// Minimal stateful thing knowing how to retrieve get/post/path data
// and knowing how to send a reply to the server.

// The code actually returning useful things such as get vars etc
// can be found in RequestResponseHelper. I hope this is a minimal desgin
// nodejs causes some overhead, some targets such as PHP don't require any
// state, thus the class is just a dummy type
import haxe.CallStack;

class RequestResponse {

  #if js
  public var urlObj: js.Node.NodeUrlObj;
  public var request: js.NodeHttpServerReq;
  public var response: js.NodeHttpServerResp;
  #elseif neko
  public var paramValues: Map<String,String>;
  #elseif JAVA_NANOHTTPD
  public var response: fi.iki.elonen.NanoHTTPD_Response;
  #end

  public var onError: web.RequestResponse -> Dynamic -> Array<haxe.StackItem> -> Void;

  #if js
  public function new(onError, request, response)
  #else
  public function new(onError)
  #end
  {
    this.onError = onError;
  #if js
    this.request = request;
    this.response = response;
    // this is very likely to be used, so do it once
    this.urlObj = js.Node.url.parse(request.url);
  #elseif neko
    this.paramValues = neko.Web.getParams();
  #end
  }
}
