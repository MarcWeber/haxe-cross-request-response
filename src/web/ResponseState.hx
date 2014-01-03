package web;
#if SERVER

import haxe.CallStack;

#if NODE_JS
import js.Node;
#end
// Minimal stateful thing knowing how to retrieve get/post/path data
// and knowing how to send a reply to the server.

// The code actually returning useful things such as get vars etc
// can be found in RequestResponseHelper. I hope this is a minimal desgin
// nodejs causes some overhead, some targets such as PHP don't require any
// state, thus the class is just a dummy type

class ResponseState {
  public var onError: web.RequestResponse -> Dynamic -> Array<haxe.StackItem> -> Void;

  #if JAVA_NANOHTTPD
    public var response: fi.iki.elonen.NanoHTTPD_Response;
  #end
  #if NODE_JS
  public var response: js.NodeHttpServerResp;
  #end

  #if js
  public function new(onError, response)
  #else
  public function new(onError)
  #end
  {
    this.onError = onError;
  }
}

#end
