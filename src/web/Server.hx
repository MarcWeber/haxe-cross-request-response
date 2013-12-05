package web;
import haxe.CallStack;
import web.Request;
import web.Response;

#if JAVA_NANOHTTPD
import fi.iki.elonen.NanoHTTPD;
#end

typedef ServerOptions = {
#if (js || JAVA_NANOHTTPD)
  port: Int
#end
}

#if JAVA_NANOHTTPD
class NanoHTTPDHx extends NanoHTTPD {

  public var process: web.RequestResponse -> Void;
  public var onError: web.RequestResponse -> Dynamic -> Array<haxe.StackItem> -> Void;

  public function new(port:Int, process, onError) {
    super(port);
    this.process  = process;
    this.onError = onError;
  }

  override public function serve(
      uri:String,
      method:fi.iki.elonen.NanoHTTPD_Method,
      headers:java.util.Map<String,
      String>,
      parms:java.util.Map<String,
      String>,
      files:java.util.Map<String,
      String>
  )
  :fi.iki.elonen.NanoHTTPD_Response 
  {
    var s = {
      request: new RequestState(),
      response: new ResponseState(this.onError)
    }
    this.process(s);
    return s.response.response;
  }

}
#end

class Server {

  static public function serve(
      process: web.RequestResponse -> Void,
      onError: web.RequestResponse -> Dynamic -> Array<haxe.StackItem> -> Void,
      options: ServerOptions
  ) {
  #if js
    js.Node.http.createServer(function(request, response){
      var s = {
        request: new RequestState(request),
        response: new ResponseState(onError, response)
      }
      try{
        process(s);
      }catch(e:Dynamic){
        s.response.onError(s, e, CallStack.exceptionStack() );
      }
    }).listen(options.port);
  #elseif (php || neko)
    var s = {
      request: new RequestState(),
      response: new ResponseState(onError)
    };
    try{
      process(s);
    }catch(e:Dynamic){
      s.response.onError(s, e, haxe.CallStack.exceptionStack() );
    }
  #elseif JAVA_NANOHTTPD
    var server = new NanoHTTPDHx(options.port, function(s){
      try{
        process(s);
      }catch(e:Dynamic){
        s.response.onError(s, e, CallStack.exceptionStack() );
      }
    }, onError);
    try{
      trace("running");
      fi.iki.elonen.ServerRunner.executeInstance(server);
      trace("done running");
    }catch(e:Dynamic){
      trace(e);
    }
  #else
    #error TODO
  #end
  }
}
